"""배포 백엔드의 더현대 지도/그래프를 촬영용 Dart 상수로 고정한다.

실행:
  cd client
  python3 promo/generate_navigation_promo_data.py

제품 코드나 백엔드 데이터는 수정하지 않는다. API 응답을 읽어 촬영 레이어 안의
`navigation_promo_data.dart`만 다시 만든다.
"""

from __future__ import annotations

import heapq
import json
import urllib.request
from pathlib import Path


CLIENT_DIR = Path(__file__).resolve().parents[1]
CONFIG_PATH = CLIENT_DIR / "config.local.json"
OUTPUT_PATH = CLIENT_DIR / "lib" / "promo" / "navigation_promo_data.dart"
BUILDING_ID = "thehyundai-seoul"
START_HINT = (72.763706, 148.812167)
DESTINATION_NAME = "스타벅스 리저브"


def get_json(base_url: str, path: str) -> dict:
    with urllib.request.urlopen(f"{base_url.rstrip('/')}{path}", timeout=30) as response:
        return json.load(response)


def nearest_b1_junction(graph: dict) -> str:
    floor_ids = {floor["name"]: floor["id"] for floor in graph["floors"]}
    candidates = [
        node
        for node in graph["nodes"]
        if node["floor_id"] == floor_ids["B1"] and node["type"] == "junction"
    ]
    return min(
        candidates,
        key=lambda node: (node["x_m"] - START_HINT[0]) ** 2
        + (node["y_m"] - START_HINT[1]) ** 2,
    )["id"]


def shortest_path(graph: dict, start_id: str, end_id: str) -> list[tuple[str, str, dict]]:
    adjacency: dict[str, list[tuple[str, dict]]] = {node["id"]: [] for node in graph["nodes"]}
    for edge in graph["edges"]:
        adjacency[edge["from"]].append((edge["to"], edge))
        if edge["bidirectional"]:
            adjacency[edge["to"]].append((edge["from"], edge))

    distances = {start_id: 0.0}
    previous: dict[str, tuple[str, dict]] = {}
    queue = [(0.0, start_id)]
    while queue:
        cost, node_id = heapq.heappop(queue)
        if cost != distances[node_id]:
            continue
        if node_id == end_id:
            break
        for next_id, edge in adjacency[node_id]:
            next_cost = cost + edge["cost_m"]
            if next_cost >= distances.get(next_id, float("inf")):
                continue
            distances[next_id] = next_cost
            previous[next_id] = (node_id, edge)
            heapq.heappush(queue, (next_cost, next_id))

    if end_id not in distances:
        raise RuntimeError("스타벅스 리저브까지 연결된 경로를 찾지 못했습니다.")

    result: list[tuple[str, str, dict]] = []
    node_id = end_id
    while node_id != start_id:
        previous_id, edge = previous[node_id]
        result.append((previous_id, node_id, edge))
        node_id = previous_id
    result.reverse()
    return result


def route_points(path: list[tuple[str, str, dict]], floor_id: str) -> list[dict]:
    points: list[dict] = []
    for from_id, to_id, edge in path:
        if edge["transfer_mode"] is not None:
            continue
        if edge["from_floor_id"] != floor_id:
            continue
        geometry = edge.get("geometry_local_m") or []
        if edge["from"] != from_id:
            geometry = list(reversed(geometry))
        for point in geometry:
            if not points or points[-1] != point:
                points.append(point)
    return points


def corridors(floor: dict) -> list[list[dict]]:
    return [
        edge["geometry_local_m"]
        for edge in floor["navigation_graph"]["edges"]
        if len(edge.get("geometry_local_m") or []) >= 2
    ]


def polygons(floor: dict) -> list[list[dict]]:
    return [store["polygon_local_m"] for store in floor["stores"] if len(store.get("polygon_local_m") or []) >= 3]


def dart_points(points: list[dict], *, wgs84: bool = False) -> str:
    x_key, y_key = ("lng", "lat") if wgs84 else ("x", "y")
    return "[" + ",".join(f"Offset({point[x_key]:.9f},{point[y_key]:.9f})" for point in points) + "]"


def dart_nested(items: list[list[dict]], *, wgs84: bool = False) -> str:
    return "[\n" + ",\n".join(f"  {dart_points(item, wgs84=wgs84)}" for item in items) + "\n]"


def dart_string(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def main() -> None:
    config = json.loads(CONFIG_PATH.read_text(encoding="utf-8"))
    base_url = config["API_BASE_URL"]
    building = get_json(base_url, f"/buildings/{BUILDING_ID}")
    b1 = get_json(base_url, f"/buildings/{BUILDING_ID}/floors/B1")
    b2 = get_json(base_url, f"/buildings/{BUILDING_ID}/floors/B2")
    graph = get_json(base_url, f"/buildings/{BUILDING_ID}/graph?vertical=auto")

    destination = next(store for store in b2["stores"] if store["name"] == DESTINATION_NAME)
    detail = get_json(
        base_url,
        f"/buildings/{BUILDING_ID}/places/{destination['id']}",
    )
    sections = detail.get("sections", [])
    summary = next(
        (section["text"] for section in sections if section.get("type") == "summary"),
        "",
    )
    hero_assets = next(
        (
            [item["local_asset"] for item in section.get("items", [])]
            for section in sections
            if section.get("type") == "hero"
        ),
        [],
    )
    business_items = next(
        (
            section.get("items", [])
            for section in sections
            if section.get("type") == "businessInfo"
        ),
        [],
    )
    address = next(
        (item["value"] for item in business_items if item.get("label") == "주소"),
        "",
    )
    start_id = nearest_b1_junction(graph)
    path = shortest_path(graph, start_id, destination["entrance_node_id"])
    floor_ids = {floor["name"]: floor["id"] for floor in graph["floors"]}
    b1_route = route_points(path, floor_ids["B1"])
    b2_route = route_points(path, floor_ids["B2"])
    transfer = next(edge for _from, _to, edge in path if edge["transfer_mode"] is not None)
    node_by_id = {node["id"]: node for node in graph["nodes"]}
    transfer_from = node_by_id[transfer["from"]]
    transfer_to = node_by_id[transfer["to"]]
    distance = sum(edge["length_m"] for _from, _to, edge in path)

    source = f"""// GENERATED FILE — promo/generate_navigation_promo_data.py
// Source: deployed {BUILDING_ID} building/floor/graph API, revision {graph['revision']}.
// Product runtime does not import this snapshot.
import 'dart:ui';

const promoDataRevision = '{graph['revision']}';
const promoRouteDistanceM = {distance:.6f};
const promoDestinationId = {dart_string(detail['id'])};
const promoDestinationName = {dart_string(detail['name'])};
const promoDestinationSubtitle = {dart_string(detail['subtitle'])};
const promoDestinationCategory = {dart_string(detail.get('subcategory') or detail.get('category') or '')};
const promoDestinationSummary = {dart_string(summary)};
const promoDestinationAddress = {dart_string(address)};
const promoDestinationHeroAssets = <String>{json.dumps(hero_assets, ensure_ascii=False)};
const promoBuildingFootprintLocal = {dart_points(building['footprint_local_m'])};
const promoBuildingFootprintWgs84 = {dart_points(building['footprint_wgs84'], wgs84=True)};
const promoB1Footprint = {dart_points(b1['footprint_local_m'])};
const promoB2Footprint = {dart_points(b2['footprint_local_m'])};
const promoB1StorePolygons = {dart_nested(polygons(b1))};
const promoB2StorePolygons = {dart_nested(polygons(b2))};
const promoB1Corridors = {dart_nested(corridors(b1))};
const promoB2Corridors = {dart_nested(corridors(b2))};
const promoB1Route = {dart_points(b1_route)};
const promoB2Route = {dart_points(b2_route)};
const promoB1TransferPoint = Offset({transfer_from['x_m']:.9f},{transfer_from['y_m']:.9f});
const promoB2TransferPoint = Offset({transfer_to['x_m']:.9f},{transfer_to['y_m']:.9f});
const promoDestinationPoint = Offset({destination['entrance_local_m']['x']:.9f},{destination['entrance_local_m']['y']:.9f});
const promoDestinationPolygon = {dart_points(destination['polygon_local_m'])};
"""
    OUTPUT_PATH.write_text(source, encoding="utf-8")
    print(
        f"generated {OUTPUT_PATH.relative_to(CLIENT_DIR)}: "
        f"B1 {len(polygons(b1))} stores, B2 {len(polygons(b2))} stores, "
        f"route {len(path)} edges / {distance:.1f}m"
    )


if __name__ == "__main__":
    main()
