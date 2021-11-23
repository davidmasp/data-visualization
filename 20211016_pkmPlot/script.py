

import os
import json
from datetime import datetime, timedelta

def read_json_file(file_path):
    """
    A function that reads a json file
    """
    with open(file_path,encoding="utf8") as f:
        data = json.load(f)
    return data

def from_js_date_to_python_date(js_date):
    """
    A function that converts a javascript date to a python date
    """
    date_dt = datetime.fromtimestamp(js_date / 1000.0)
    return date_dt.strftime('%Y-%m-%dT%H:%M:%S.%fZ')

def extract_data(data):
    exported_date = data["exportDate"]
    docs_array = data["docs"]
    nodes_array = []
    links_array = []
    for doc in docs_array:
        tmp_dict = {
            "id": doc["_id"],
            "start": from_js_date_to_python_date(doc["createdAt"]),
            "end":  exported_date
        }
        nodes_array.append(tmp_dict)
        ## first I create the links with the referenced nodes
        ## some docs do not have references for some reason
        if 'references' in doc:
            references = doc["references"]
            if len(references) == 0:
                next
            for ref in references:
                ## print(ref_id)
                ref_id = ref["q"]
                link_dict = {
                    "source": ref_id,
                    "target": doc["_id"],
                    "start": from_js_date_to_python_date(doc["createdAt"]),
                    "end": exported_date
                }
                links_array.append(link_dict)
        ## now I create the links with the children
        children = doc["children"]
        for child in children:
            child_id = child
            link_dict = {
                "source": child_id,
                "target": doc["_id"],
                "start": from_js_date_to_python_date(doc["createdAt"]),
                "end": exported_date
            }
            links_array.append(link_dict)
    return nodes_array, links_array

def clean_links(links, nodes):
    links_array = []
    all_nodes_id = [i["id"] for i in nodes]
    links_array = [i for i in links if i["source"] in all_nodes_id and i["target"] in all_nodes_id]
    nodes_tmp = {}
    for i in nodes:
        nodes_tmp[i["id"]] = i["start"]
    links_array_clean = []
    for link in links_array:
        src = nodes_tmp[link["source"]]
        trg = nodes_tmp[link["target"]]
        tmp_times = [src, trg]
        tmp_times.sort()
        ## 1 because I need the latest time
        link["start"] = tmp_times[1]
        links_array_clean.append(link)
    return links_array_clean

def export_to_json(dict, out_path):
    with open(out_path, "w") as f:
        json.dump(dict, f)

def create_times_array(nodes):
    times = []
    for i in nodes:
        times.append(i["start"])
        times.append(i["end"])
    times.sort()
    return times[0], times[-1]

def create_times_ranges(times, days_step = 31):
    times_ranges = []
    start_time = times[0]
    end_time = times[1]
    times_ranges.append(start_time)
    while times_ranges[-1] < end_time:
        tmp_time = times_ranges[-1]
        datetime_obj = datetime.strptime(tmp_time, '%Y-%m-%dT%H:%M:%S.%fZ')
        datetime_obj2 = datetime_obj + timedelta(days=days_step)
        tmp_interval = datetime_obj2.strftime('%Y-%m-%dT%H:%M:%S.%fZ')
        times_ranges.append(tmp_interval)
    return times_ranges

if __name__ == "__main__":
    fn = "raw_data/rem.json"
    data = read_json_file(fn)
    nodes, links_raw = extract_data(data)
    links = clean_links(links_raw, nodes)
    print(len(nodes))
    print(len(links))
    obj_ret = {
        "nodes": nodes,
        "links": links
    }
    os.mkdir("data")
    export_to_json(nodes, "data/nodes.json")
    export_to_json(links, "data/links.json")
    export_to_json(obj_ret,"data/nodeslinks.json")
    times = create_times_array(nodes)
    time_range = create_times_ranges(times, 10)
    export_to_json(time_range, "data/times.json")
