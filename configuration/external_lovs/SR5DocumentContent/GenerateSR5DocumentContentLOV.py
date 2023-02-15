import pandas as pd
from datetime import datetime


def generate_lov(lov_data_level0, lov_data_level1):
    excludeClasses = ["BF", "CC", "CD", "CE"]
    today = datetime.now().strftime("%a %b %d %I:%M:%S %p %Y")
    with open("SR5DocumentContent.xml", "a", encoding="utf-8") as valuesXML:
        # Generate the values XML
        valuesXML.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
        valuesXML.write(
            f"  <TcBusinessData xmlns=\"http://teamcenter.com/BusinessModel/TcBusinessData\" batchXSDVersion=\"1.0\" Date=\"{today}\">\n")
        valuesXML.write("    <Add>\n")
        for value in lov_data_level0["dcc"]:
            if value in excludeClasses:
                continue
            valuesXML.write(
                f"      <TcLOVValueSubLOVAttach conditionName=\"isTrue\" subLOVName=\"SR5DocumentContent_{value}\" targetLOVName=\"SR5DocumentContent\" targetValue=\"{value}\"/>\n")
        valuesXML.write("    </Add>\n")
        valuesXML.write("    <Change>\n")
        valuesXML.write(
            "      <TcLOV name=\"SR5DocumentContent\" lovType=\"ListOfValuesString\" usage=\"Exhaustive\" description=\"\" isManagedExternally=\"true\">\n")
        for value in lov_data_level0["dcc"]:
            if value in excludeClasses:
                continue
            valuesXML.write(
                f"        <TcLOVValue value=\"{value}\" description=\"\" conditionName=\"isTrue\"/>\n")
        valuesXML.write("      </TcLOV>\n")
        for value in lov_data_level0["dcc"].unique():
            temp_sub_df = lov_data_level1[lov_data_level1["main_class"] == value]
            valuesXML.write(
                f"      <TcLOV name=\"SR5DocumentContent_{value}\" lovType=\"ListOfValuesString\" usage=\"Exhaustive\" description=\"\" isManagedExternally=\"true\">\n")
            for value1 in temp_sub_df["dcc"]:
                valuesXML.write(
                    f"        <TcLOVValue value=\"{value1}\" description=\"\" conditionName=\"isTrue\"/>\n")
            valuesXML.write("      </TcLOV>\n")
        valuesXML.write("    </Change>\n")
        valuesXML.write("  </TcBusinessData>\n")
        # Generate the en_US localization XML
        filename = f"lang/SR5DocumentContent_en_US.xml"
        with open(filename, "a", encoding="utf-8") as localizedValuesXML:
            localizedValuesXML.write(
                "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
            localizedValuesXML.write(
                f"  <TcBusinessDataLocalization xmlns=\"http://teamcenter.com/BusinessModel/TcBusinessDataLocalization\" batchXSDVersion=\"1.0\" Date=\"{today}\">\n")
            localizedValuesXML.write("    <Add>\n")
            for index, row in lov_data_level0.iterrows():
                localizedValuesXML.write(
                    f"      <key locale=\"en_US\" id=\"LOVValue{{::}}SR5DocumentContent{{::}}{row['dcc']}\" status=\"Approved\">{row['dcc']} - {row['disp_value_en_US']}</key>\n")
                localizedValuesXML.write(
                    f"      <key locale=\"en_US\" id=\"LOVValueDescription{{::}}SR5DocumentContent{{::}}{row['dcc']}\" status=\"Approved\"></key>\n")
            for index, row in lov_data_level1.iterrows():
                localizedValuesXML.write(
                    f"      <key locale=\"en_US\" id=\"LOVValue{{::}}SR5DocumentContent_{row['main_class']}{{::}}{row['dcc']}\" status=\"Approved\">{row['dcc']} - {row['disp_value_en_US']}</key>\n")
                localizedValuesXML.write(
                    f"      <key locale=\"en_US\" id=\"LOVValueDescription{{::}}SR5DocumentContent_{row['main_class']}{{::}}{row['dcc']}\" status=\"Approved\"></key>\n")
            localizedValuesXML.write("    </Add>\n")
            localizedValuesXML.write("  </TcBusinessDataLocalization>")
        # Generate the de_DE localization XML
        filename = f"lang/SR5DocumentContent_de_DE.xml"
        with open(filename, "a", encoding="utf-8") as localizedValuesXML:
            localizedValuesXML.write(
                "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
            localizedValuesXML.write(
                f"  <TcBusinessDataLocalization xmlns=\"http://teamcenter.com/BusinessModel/TcBusinessDataLocalization\" batchXSDVersion=\"1.0\" Date=\"{today}\">\n")
            localizedValuesXML.write("    <Add>\n")
            for index, row in lov_data_level0.iterrows():
                localizedValuesXML.write(
                    f"      <key locale=\"de_DE\" id=\"LOVValue{{::}}SR5DocumentContent{{::}}{row['dcc']}\" status=\"Approved\">{row['dcc']} - {row['disp_value_de_DE']}</key>\n")
                localizedValuesXML.write(
                    f"      <key locale=\"de_DE\" id=\"LOVValueDescription{{::}}SR5DocumentContent{{::}}{row['dcc']}\" status=\"Approved\"></key>\n")
            for index, row in lov_data_level1.iterrows():
                localizedValuesXML.write(
                    f"      <key locale=\"de_DE\" id=\"LOVValue{{::}}SR5DocumentContent_{row['main_class']}{{::}}{row['dcc']}\" status=\"Approved\">{row['dcc']} - {row['disp_value_de_DE']}</key>\n")
                localizedValuesXML.write(
                    f"      <key locale=\"de_DE\" id=\"LOVValueDescription{{::}}SR5DocumentContent_{row['main_class']}{{::}}{row['dcc']}\" status=\"Approved\"></key>\n")
            localizedValuesXML.write("    </Add>\n")
            localizedValuesXML.write("  </TcBusinessDataLocalization>")
    print("Files generated")


if __name__ == "__main__":
    df = pd.read_excel("SR5DocumentContent.xlsx", header=2)
    df_preprocessing = df[["A2 A3", "DE description (gekürzt auf 30 Zeichen)", "EN description (target short form)",
                           "ES description (has to be completely translated) (target short form)"]]
    df_clean = df_preprocessing.rename(columns={"A2 A3": "dcc", "DE description (gekürzt auf 30 Zeichen)": "disp_value_de_DE",
                                       "EN description (target short form)": "disp_value_en_US", "ES description (has to be completely translated) (target short form)": "disp_value_es_ES"})
    df_level0 = df_clean[df_clean["dcc"].str.match("^[A-Z]{2}$")].copy()
    df_level1 = df_clean[df_clean["dcc"].str.match(
        "^[A-Z]{2}[0-9]{4}$")].copy()
    df_level1["main_class"] = df_level1["dcc"].str[0:2]
    generate_lov(df_level0, df_level1)
