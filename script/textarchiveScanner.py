#!/usr/bin/env python
# coding: utf-8

from pyquery import PyQuery as pq
import requests
import MySQLdb

import datetime
import re
import csv
from collections import OrderedDict

inputFilename = "../datafiles/Criminal Calendar.csv"

db = MySQLdb.connect(
    host="localhost",
    user="cpersaud",
    password="Post1234",
    db="daily_court_docket"
)

todayDate = datetime.datetime.now().strftime("%Y-%m-%d")

# todayDate='2019-02-28'   ############################ HEY!


urldict = {}
keylist = []

cursor = db.cursor()
cursor.execute("CREATE TABLE IF NOT EXISTS defendants_broad (row_id INT, case_num VARCHAR(255), defendant VARCHAR(255), recent_events VARCHAR(255), num_matches INT, search_result_url VARCHAR(255), scan_date DATE, UNIQUE(case_num), PRIMARY KEY(row_id))")
cursor.execute("CREATE TABLE IF NOT EXISTS defendants_narrow (row_id INT, case_num VARCHAR(255), defendant VARCHAR(255), recent_events VARCHAR(255), num_matches INT, search_result_url VARCHAR(255), scan_date DATE, UNIQUE(case_num), PRIMARY KEY(row_id))")
cursor.execute("CREATE TABLE IF NOT EXISTS charges (row_id INT, charge VARCHAR(255), case_num VARCHAR(255), scan_date DATE)")

with open(inputFilename) as f:
    reader = csv.DictReader(f)
    for row in reader:
        caseNum = row["CaseNumber2"]

        defendantFullName = row["DefendantName1"]
        defendantNameSplit = defendantFullName.split(", ")
        defendantLastName = defendantNameSplit[0]
        defendantFirstName = defendantNameSplit[1].split(' ')[0]
        defendantFirstLastName = defendantFirstName + ' ' + defendantLastName

        courtEvent = row["CourtEventTypeStr"]
        
        charge = row['StatuteDescription']
        
        if charge != '':
            cursor.execute("""INSERT INTO charges (charge, case_num, scan_date) values (%s, %s, %s);""", [charge, caseNum, todayDate])
            
        key = "!!!!".join([caseNum,defendantFirstLastName, courtEvent])
        
        if key not in keylist:   # If we've already searched on this person and written on 'em, no need to do it again
            keylist.append(key)

            # URLs with defendant's name, which we'll search in PBP clips
            urlBroad = "http://nl.newsbank.com/nl-search/we/Archives?p_product=PBPB&p_theme=pbpb&p_action=search&p_maxdocs=200&s_hidethis=no&p_field_label-0=Author&p_field_label-1=title&p_bool_label-1=AND&s_dispstring=%22'"+defendantFirstName+"'%20'"+defendantLastName+"+'%22%20AND%20date%2801/01/1989%20to%2012/31/2014%29&p_field_date-0=YMD_date&p_params_date-0=date:B,E&p_text_date-0=01/01/1989%20to%2012/31/2014%29&p_field_advanced-0=&p_text_advanced-0=%28%22'+defendantFirstName+'%20'+defendandLastName+'%22%29&xcal_numdocs=40&p_perpage=20&p_sort=YMD_date:D&xcal_useweights=no"
            urlNarrow = "http://nl.newsbank.com/nl-search/we/Archives?p_product=PBPB&p_theme=pbpb&p_action=search&p_maxdocs=200&s_hidethis=no&p_field_label-0=Author&p_field_label-1=title&p_bool_label-1=AND&s_dispstring=%22'"+defendantFirstName+"'%20'"+defendantLastName+"+'%22%20AND%20%28jail%20OR%20police%20OR%20sheriff%20OR%20bail%29%20AND%20date%28all%29&p_field_advanced-0=&p_text_advanced-0=%22'"+defendantFirstName+"'%20'"+defendantLastName+"'%22%20AND%20%28jail%20OR%20police%20OR%20sheriff%20OR%20bail%29&xcal_numdocs=40&p_perpage=20&p_sort=YMD_date:D&xcal_useweights=no"

            tblDict = {
                "defendants_broad": urlBroad,
                "defendants_narrow": urlNarrow
            }

            for tblName, url in tblDict.items():
                # Let's start caching URLs so we don't hit the server all the time
                if url in urldict:
                    numberOfResults = urldict[url]
                else:
                    html = requests.get(url).content    # Searching PBP clips for defendant's name and getting resulting web page
                    numberOfResults = re.findall(r"\d{1,}",pq(html)("#nBasdiv960 p[style='font-size:0.917em']").text().strip())[-1] if pq(html)("#nBasdiv960 p")[3].text==None else pq(html)("#nBasdiv960 p")[3].text
                    urldict[url] = numberOfResults
                print([caseNum, defendantFirstLastName, courtEvent, numberOfResults, url, todayDate])
                dataRow = ['"'+caseNum+'"', '"'+defendantFirstLastName+'"', '"'+courtEvent+'"', '"'+numberOfResults+'"', '"'+url+'"', '"'+todayDate+'"']
                try:
                    cursor.execute("INSERT INTO "+tblName+"(case_num, defendant, recent_event, num_matches, search_result_url, scan_date)  VALUES("+ ','.join(dataRow) +')')
                except Exception as ex:
                    template = "An exception of type {0} occurred. Arguments:\n{1!r}"
                    message = template.format(type(ex).__name__, ex.args)
                    print(message)
                    # sql = "UPDATE "+tblName+" SET num_matches="+numberOfResults+" WHERE case_num='"+caseNum+"'" if courtEvent=='' else "UPDATE "+tblName+" SET num_matches="+numberOfResults+", recent_event='"+courtEvent+"' WHERE case_num='"+caseNum+"'"
                    sql = f"UPDATE {tblName} SET num_matches={numberOfResults}, recent_event='{courtEvent}', scan_date='{todayDate}' where case_num='{caseNum}';"
                    if courtEvent == '':
                        sql.replace(f"recent_event='{courtEvent}', ", "")
                    # print(f"HEY!   {sql}")    
                    cursor.execute(sql)
                    # db.commit()
                print("==")
            print("======")

db.commit()     # Write all pending transactions            

cursor.execute(
    """ SELECT
           t1.case_num,
           t1.scan_date,
           t1.recent_event,
           t1.defendant,
           t3.charge,
           t1.num_matches,
           t2.num_matches,
           t2.search_result_url
      FROM (
           SELECT *
           FROM defendants_broad
           WHERE scan_date = '"""+todayDate+"""'
      ) AS t1
      INNER JOIN (
           SELECT *
           FROM defendants_narrow
           WHERE scan_date = '"""+todayDate+"""'
      ) AS t2
      ON t1.case_num = t2.case_num
      INNER JOIN (
           SELECT *
           FROM charges
           WHERE scan_date = '"""+todayDate+"""'
      ) AS t3
      ON t1.case_num = t3.case_num
      ORDER BY
           t2.num_matches DESC,
           t2.defendant ASC """
)

rows = cursor.fetchall()
# headers = [col[0] for col in cursor.description]    # get headers
headers = tuple(["Case Number", "Scanned date", "Recent event", "Defendant", "Charge", "Match count (broad)", "Match count (narrow)", "Search results URL (narrow)"])
rows = (tuple(headers),) + rows     # add headers to rows
fp = open("../datafiles/defendants_"+todayDate+".csv", 'w', newline='')
myFile = csv.writer(fp)
# myFile.writerow(headers)
myFile.writerows(rows)
fp.close()

print("Court records CSV made")
