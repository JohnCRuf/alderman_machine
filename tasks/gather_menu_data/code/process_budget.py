import csv
import re
import sys


def get_category(program, dept=""):
    if dept == "CDOT: DEO" or any(
        w in program for w in ["Light", "LED", "Signal", "Floodlight", "Arrow", "Flash"]
    ):
        return "Lighting"
    if any(
        w in program.lower()
        for w in [" arts ", " art ", "mural", "sculpture", "public art", "mosaic"]
    ):
        return "Arts"
    if dept == "CDOT: COMM" or any(
        w in program
        for w in [
            "Alley",
            "alleys",
            "Pavement",
            "Curb",
            "Sidewalk",
            "Resurfa",
            "In-Road",
            "CDOT",
            "Bollard",
            "Bump",
            "Hump",
            "Speed",
            "Pedestrian",
            "Parking",
            "Viaduct",
            "Highway",
            "Lane",
            "Traffic",
            "Bus Pad",
            "Ramp",
            "Median",
            "Underpass",
            "Boulevard",
            "-de-",  # Cul-de-sac
        ]
    ):
        return "Streets/CDOT"
    if "camera" in program.lower():
        return "Cameras"
    if any(
        w in program for w in ["School", "Elementary", "Academy", "College Prep", "CPS"]
    ):
        return "Schools"
    if "librar" in program.lower():
        return "Libraries"
    if any(
        w in program.lower()
        for w in [
            "park",
            "pond",
            "greenway",
            " beach",
            "landscap",
            "baseball",
            "playlot",
            "swings",
        ]
    ):
        return "Parks"
    if any(w in program for w in ["Tree", "Garden"]):
        return "Trees, Gardens"
    if "Misc" in program:
        return "Misc"
    return "Other"

def process_old(stdin, year):
    rows = []
    ward = ""
    dept = ""
    program = ""
    csv_rows = [row for row in csv.reader(stdin)]
    for idx, row in enumerate(csv_rows):
        paren_match = re.search(r"^\([\d\-]{1,3}\)$", row[0].strip())
        if (
            row[0].strip() == ""
            or paren_match
            or all(c.strip() == "" for c in row)
            or any(
                any(w in c for w in ["Page ", "Budget", "Full Address"]) for c in row
            )
        ):
            continue

        dept_match = re.search(r"[A-Z]{2,6}\s*:\s*[A-Z]{2,6}", row[0])
        if dept_match:
            dept = dept_match.group().replace(" :", ":")
        elif row[0].startswith("Program"):
            program = row[0].split(":")[-1].strip()
        elif idx > 0 and csv_rows[idx - 1][0].startswith("Program"):
            program = " ".join([program, row[0].strip()])
        elif "Ward" in row[0]:
            ward = row[0].split(":")[-1].strip()
        elif all(c.strip() == "" for c in row[1:]):
            # Is address, append to last address row
            sys.stdout.write("Hello")

            #rows[-1]["location"] += " " + row[0].strip()
        else:
            rows.append(
                {
                    "year": year,
                    "ward": ward,
                    "dept": dept,
                    "program": program,
                    "location": row[0].strip(),
                    "desc": row[1].strip(),
                    "blocks": row[2],
                    "unit_count": row[3],
                    "est_cost": row[4],
                }
            )
    for row in rows:
        row["desc"] = re.sub(r"\s+", " ", row["desc"]).strip()
        row["location"] = re.sub(r"\s+", " ", row["location"]).strip()
        row["location"] = re.sub(r"(?<=[A-Z])&(?=[A-Z])", " & ", row["location"])
        row["category"] = get_category(row["program"], dept=row["dept"])
    return rows

def process_2011(stdin, year):
    rows = []
    ward = ""
    dept = ""
    program = ""
    csv_rows = [row for row in csv.reader(stdin)]
    for idx, row in enumerate(csv_rows):
        paren_match = re.search(r"^\([\d\-]{1,3}\)$", row[0].strip())
        if (
            row[0].strip() == ""
            or paren_match
            or all(c.strip() == "" for c in row)
            or any(
                any(w in c for w in ["Page ", "Budget", "Full Address"]) for c in row
            )
        ):
            continue

        dept_match = re.search(r"[A-Z]{2,6}\s*:\s*[A-Z]{2,6}", row[0])
        if dept_match:
            dept = dept_match.group().replace(" :", ":")
        elif row[0].startswith("Program"):
            program = row[0].split(":")[-1].strip()
        elif idx > 0 and csv_rows[idx - 1][0].startswith("Program"):
            program = " ".join([program, row[0].strip()])
        elif "Ward" in row[0]:
            ward = row[0].split(":")[-1].strip()
        else:
            rows.append(
                {
                    "year": year,
                    "ward": ward,
                    "dept": dept,
                    "program": program,
                    "location": row[0].strip(),
                    "desc": row[1].strip(),
                    "blocks": row[2],
                    "unit_count": row[3],
                    "est_cost": row[4],
                }
            )
    for row in rows:
        row["desc"] = re.sub(r"\s+", " ", row["desc"]).strip()
        row["location"] = re.sub(r"\s+", " ", row["location"]).strip()
        row["location"] = re.sub(r"(?<=[A-Z])&(?=[A-Z])", " & ", row["location"])
        row["category"] = get_category(row["program"], dept=row["dept"])
    return rows

def process_early(stdin, year):
    rows = []
    ward = ""
    dept = ""
    program = ""
    csv_rows = [row for row in csv.reader(stdin)]
    for idx, row in enumerate(csv_rows):
        paren_match = re.search(r"^\([\d\-]{1,3}\)$", row[0].strip())
        if (
            row[0].strip() == ""
            or paren_match
            or all(c.strip() == "" for c in row)
            or any(
                any(w in c for w in ["Page ", "Budget", "Full Address"]) for c in row
            )
        ):
            continue

        dept_match = re.search(r"[A-Z]{2,6}\s*:\s*[A-Z]{2,6}", row[0])
        if dept_match:
            dept = dept_match.group().replace(" :", ":")
        elif row[0].startswith("Program"):
            program = row[0].split(":")[-1].strip()
        elif idx > 0 and csv_rows[idx - 1][0].startswith("Program"):
            program = " ".join([program, row[0].strip()])
        elif "Ward" in row[0]:
            ward = row[0].split(":")[-1].strip()
        elif all(c.strip() == "" for c in row[1:]):
            # Is address, append to last address row
            rows[-1]["location"] += " " + row[0].strip()
        else:
            rows.append(
                {
                    "year": year,
                    "ward": ward,
                    "dept": dept,
                    "program": program,
                    "location": row[0].strip(),
                    "desc": row[1].strip(),
                    "blocks": row[2],
                    "unit_count": row[3],
                    "est_cost": row[4],
                }
            )
    for row in rows:
        row["desc"] = re.sub(r"\s+", " ", row["desc"]).strip()
        row["location"] = re.sub(r"\s+", " ", row["location"]).strip()
        row["location"] = re.sub(r"(?<=[A-Z])&(?=[A-Z])", " & ", row["location"])
        row["category"] = get_category(row["program"], dept=row["dept"])
    return rows


def process_recent(stdin, year):
    rows = []
    ward = ""
    for idx, row in enumerate(csv.reader(stdin)):
        if all(c.strip() == "" for c in row) or any(
            w in row[0] for w in ["MenuPackage", "TOTAL", "MENU BUDGET", "BALANCE"]
        ):
            continue
        if row[0].startswith("Ward:"):
            ward = row[0].split(":")[-1].strip()
        elif len(rows) > 0 and rows[-1]["est_cost"] == "":
            for idx, field in enumerate(["program", "location", "est_cost"]):
                rows[-1][field] = " ".join([rows[-1][field], row[idx].strip()]).strip()
        else:
            if len(row) == 1:
                cost_temp = "NA"
            else:
                cost_temp = row[2].strip()
            rows.append(
                {
                    "year": year,
                    "ward": ward,
                    "dept": "",
                    "program": row[0].strip(),
                    "location": row[1].strip(),
                    "desc": "",
                    "blocks": "",
                    "unit_count": "",
                    "est_cost": cost_temp,
                }
            )
    for row in rows:
        row["program"] = re.sub(r"\s+", " ", row["program"]).strip()
        row["location"] = re.sub(r"\s+", " ", row["location"]).strip()
        row["location"] = re.sub(r"(?<=[A-Z])&(?=[A-Z])", " & ", row["location"])
        row["category"] = get_category(row["program"])
    return rows


if __name__ == "__main__":
    if sys.argv[1] < "2011":
        rows = process_old(sys.stdin, sys.argv[1])
    elif sys.argv[1] == "2011":
        rows = process_2011(sys.stdin, sys.argv[1])
    elif sys.argv[1] < "2016" and sys.argv[1] > "2011":
        rows = process_early(sys.stdin, sys.argv[1])
    else:
        rows = process_recent(sys.stdin, sys.argv[1])
    writer = csv.DictWriter(
        sys.stdout,
        fieldnames=[
            "year",
            "ward",
            "dept",
            "program",
            "category",
            "location",
            "desc",
            "blocks",
            "unit_count",
            "est_cost",
        ],
    )
    writer.writeheader()
    writer.writerows(rows)