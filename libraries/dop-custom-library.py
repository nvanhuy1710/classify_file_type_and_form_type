import pandas as pd
from bs4 import BeautifulSoup

def isNaN(string):
    return string != string

def html_to_text(html):
    soup = BeautifulSoup(html, "html.parser")
    return soup.get_text()

def find_cell_with_text(df, target_text):
    well_name_list = []
    for row_index, row in df.iterrows():
        for col_index, cell_value in row.items():
            if str(target_text) in str(cell_value):
                well_name_list.append(cell_value)
    return well_name_list

def get_rows_between_invoice_and_well_name(df):
    datas = df.values.tolist()
    data_length =  len(datas)

    x = range(9, data_length)
    items = []
    amounts = []
    for i in x:
        if "Well Name" in str(datas[i][1]):
            break
        if isNaN(datas[i][1]):
            continue
        items.append(datas[i][1])
        amounts.append(datas[i][3])

    return items, amounts

def read_file_excel_form_key_don_brock(path):
    df = pd.read_excel(path)

    vendor = df.at[0, 'INVOICE']

    total_invoice_row = df[df['Unnamed: 2'] == 'TOTAL']
    total_invoice_value = total_invoice_row['Unnamed: 3'].values[0] if not total_invoice_row.empty else None

    date_row = df[df['Unnamed: 2'] == 'DATE:']
    date_value = date_row['Unnamed: 3'].values[0] if not date_row.empty else None

    invoice_number_row = df[df['Unnamed: 2'] == 'INVOICE #']
    invoice_number_value = invoice_number_row['Unnamed: 3'].values[0] if not invoice_number_row.empty else None
    transaction_date_value =None

    transaction_date_rows = df[df.apply(lambda row: 'Transaction Date' in row.values, axis=1)]

    transaction_date_value = None
    for index, row in transaction_date_rows.iterrows():
        data_series = pd.Series(row)
        transaction_date_value = data_series['Unnamed: 2']

    result_well_name = find_cell_with_text(df, "Well Name")
    items_name, amounts = get_rows_between_invoice_and_well_name(df)
    
    return vendor, total_invoice_value, date_value, invoice_number_value, transaction_date_value, result_well_name, items_name, amounts