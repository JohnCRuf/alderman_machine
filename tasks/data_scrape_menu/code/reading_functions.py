def location_street_filter(string):
    title_list = ["ST", "AVE", "BV", "BLVD", "RD", "PL", "CT", "DR", "LN", "PKWY", "WAY", "TER", "CIR", "SQ", "PLZ", "HWY", "TR", "ALY", "PARK", "PARKWAY", "STREET", "AVENUE", "BOULEVARD", "ROAD", "PLACE", "COURT", "DRIVE", "LANE", "PARKWAY", "WAY", "TERRACE", "CIRCLE", "SQUARE", "PLAZA", "HIGHWAY", "TRAIL", "ALLEY", "PARK", "PARKWAY"]
    direction_list = ["N", "S", "E", "W"]
    front_combo_list = [title + "" + direction for title in title_list for direction in direction_list]
    back_combo_list = [direction + "" + title for title in title_list for direction in direction_list]

    def replace_combo(match):
        combo = match.group(0)
        if combo in front_combo_list:
            last_character_combo = combo[-1]
            rest_of_combo = combo[:-1]
            return rest_of_combo + " " + last_character_combo
        elif combo in back_combo_list:
            first_character_combo = combo[0]
            rest_of_combo = combo[1:]
            return first_character_combo + " " + rest_of_combo
        else:
            return combo

    return re.sub(r'\b(?:{})\b'.format('|'.join(front_combo_list + back_combo_list)), replace_combo, string)

def location_parenthesis_filter(string):
    direction_list = ["N", "S", "E", "W"]
    front_parenthesis_error_list = [")" + direction for direction in direction_list]
    front_correction_list = [") " + direction for direction in direction_list]
    back_parenthesis_error_list = [direction + "(" for direction in direction_list]
    back_correction_list = [direction + " (" for direction in direction_list]
    for front_error, front_correction in zip(front_parenthesis_error_list, front_correction_list):
        string = string.replace(front_error, front_correction)
    for back_error, back_correction in zip(back_parenthesis_error_list, back_correction_list):
        string = string.replace(back_error, back_correction)
    return string
def location_ampersand_filter(string):
    string = string.replace('&', ' & ')
    return string