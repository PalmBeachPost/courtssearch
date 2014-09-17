[
	'rubygems',
	'open-uri',
	'nokogiri',
	'sequel',
	'sqlite3',
	'csv'
].each{|g|
	require g
}

today_date = (Time.now).strftime("%Y-%m-%d")

memoryDB = Sequel.sqlite # In-memory database. When the script is done, this database is forgotten.

# Login info for `daily_court_docket` database
DB = Sequel.connect(
    :adapter => 'mysql',
    :user=>'cpersaud',
    :password=>'Post1234',
    :host=>'NWPBPBP0DPC2334.cmg.int',
    :database=>'daily_court_docket'
)

# In this loop, we call each database `dbase`
[DB,memoryDB].each{|dbase|
	# Create this table if it isn't already there
	dbase.create_table? :defendants_broad do 
		primary_key :row_id
		String :case_num, :unique=>true
		String :defendant
		String :recent_event
		Integer :num_matches
		Text :search_result_url
		Date :scan_date
	end

	dbase.create_table? :defendants_narrow do 
		primary_key :row_id
		String :case_num, :unique=>true
		String :defendant
		String :recent_event
		Integer :num_matches
		Text :search_result_url
		Date :scan_date
	end	

	dbase.create_table? :charges do 
		primary_key :row_id
		String :charge
		String :case_num
		Date :scan_date
	end

	defendants_broad = dbase[:defendants_broad]
	defendants_narrow = dbase[:defendants_narrow]
	charges = dbase[:charges]

	case_num = nil

	# Read Kathy's CSV file, starting with the fifth line onwards to the last. 
	# The first line is at position 0, so the fifth is at position 4.
	# When reading the CSV, we call each line `row`
	CSV.read("../datafiles/Court Calendar.csv")[4..-1].map{|row|
		# If the fifth cell from the left of a `row` is not empty...
		if(row[4]!=nil)
			case_num = row[5] # DATAPOINT!!

			name_arr = row[4].split(',') # An array for the defendant's name. The name info is in the fifth cell from the right in this row. `name_arr` looks something like ["GOODE","JOHNATHAN B"]
			first_name = name_arr[1].split(' ')[0] # Example: ["JOHNATHAN B"] #=> ["JOHNATHAN", "B"] #=> "JOHNATHAN"
			# middle_name = name_arr[1].split(' ')[1] === nil ? '' : name_arr[1].split(' ')[1] # We may not need a middle name...
			last_name = name_arr[0] # DATAPOINT!! The first element in `name_arr`. In our example: "GOODE"
			first_last = first_name+' '+last_name # DATAPOINT!! In our example: "JOHNATHAN GOODE"

			recent_event = row[18] # DATAPOINT!!

			# These URL strings contain the info for searching our defendant in the Palm Beach Post's archives.
			# In `url_broad`, we just search "JOHNATHAN GOODE".
			# In `url_narrow`, we search "JOHNATHAN GOODE" along with words like "JAIL", "SHERIFF", etc.
			url_broad = 'http://nl.newsbank.com/nl-search/we/Archives?p_product=PBPB&p_theme=pbpb&p_action=search&p_maxdocs=200&s_hidethis=no&p_field_label-0=Author&p_field_label-1=title&p_bool_label-1=AND&s_dispstring=%22'+first_name+'%20'+last_name+'%22%20AND%20date%2801/01/1989%20to%2012/31/2014%29&p_field_date-0=YMD_date&p_params_date-0=date:B,E&p_text_date-0=01/01/1989%20to%2012/31/2014%29&p_field_advanced-0=&p_text_advanced-0=%28%22'+first_name+'%20'+last_name+'%22%29&xcal_numdocs=40&p_perpage=20&p_sort=YMD_date:D&xcal_useweights=no'
			url_narrow = 'http://nl.newsbank.com/nl-search/we/Archives?p_product=PBPB&p_theme=pbpb&p_action=search&p_maxdocs=200&s_hidethis=no&p_field_label-0=Author&p_field_label-1=title&p_bool_label-1=AND&s_dispstring=%22'+first_name+'%20'+last_name+'%22%20AND%20%28jail%20OR%20police%20OR%20sheriff%20OR%20bail%29%20AND%20date%28all%29&p_field_advanced-0=&p_text_advanced-0=%22'+first_name+'%20'+last_name+'%22%20AND%20%28jail%20OR%20police%20OR%20sheriff%20OR%20bail%29&xcal_numdocs=40&p_perpage=20&p_sort=YMD_date:D&xcal_useweights=no'

			# In this hash, the broad data table refers to the broad search, and the narrow table to the narrow search
			tbl_hsh = {
				defendants_broad => url_broad,
				defendants_narrow => url_narrow
			}

			# In this `each_pair` loop, we insert data into the broad and narrow-search tables
			tbl_hsh.each_pair{|tbl, url|
				# If there's a problem opening the search page with our search string, skip to the next `row`
				begin
					page = Nokogiri::HTML(open(url)) # This variable is the search results page
				rescue Exception => e
					p "ERROR OPENING #{url}: #{e}"
					next
				end
				
				p = page.css('p[style="font-size:0.917em"]')[1] # The tag that has the number of results
				num_matches = p.text.strip.scan(/\d{1,}/)[1].to_i # The number of articles containing what we searched for

				match_arr = [case_num, first_last, recent_event, num_matches, url]
				
				# If there's a problem inserting data into the table, it's usually because we're trying to insert data for a case already in the table.
				# In that case, we find the row with the case number, and update it with our new info
				begin
					tbl.insert(
						:case_num => case_num,
						:defendant => first_last,
						:recent_event => recent_event,
						:num_matches => num_matches,
						:search_result_url => url,
						:scan_date =>  today_date
					)

					# f.puts(match_arr.to_csv)
					p match_arr				
				rescue Exception => e
					p "ERROR INSERTING DATA: #{e}"
					
					tbl.where(
						"case_num = ?",
						case_num
					).update(
						:recent_event => recent_event,
						:num_matches => num_matches,
						:search_result_url => url,
						:scan_date =>  today_date
					)

					p match_arr
				end
			} # DONE: [url_broad, url_narrow].each
		else
			# If the 28th cell from the left is not empty...
			if( row[27]!=nil )
				charge_arr = [ case_num, row[27], today_date ]

				# Inserting charge data into charge data table
				charges.insert(
					:charge => row[27],
					:case_num => case_num,
					:scan_date => today_date
				)

				p charge_arr
			end
		end # DONE: if(row[4]!=nil)
	} # DONE: CSV.read("../datafiles/Court Calendar.csv")[4..30].map
} # DONE: [DB,memoryDB].each


headers = [
	"Case Number",
	"Scanned date",
	"Recent event",
	"Defendant",
	"Charge",
	"Match count (broad)",
	"Match count (narrow)",
	"Search results URL (narrow)"
]

# Create a new CSV with today's date in the filename
File.open("../datafiles/defendants_"+today_date+".csv", "w"){|f|
	f.puts(headers.to_csv)
	p headers

	# Running this SQL query on the in-memory database, which is smaller than the MySQL one.
	# This query gets the info specified in `headers` array
	memoryDB[
		"SELECT 
			t1.case_num,
			STRFTIME('%Y-%m-%d',t1.scan_date),
			t1.recent_event,
			t1.defendant,
			t3.charge,
			t1.num_matches,
			t2.num_matches,
			t2.search_result_url
		FROM (
			SELECT *
			FROM defendants_broad
			WHERE scan_date = \"#{today_date}\"
		) AS t1
		INNER JOIN (
			SELECT *
			FROM defendants_narrow
			WHERE scan_date = \"#{today_date}\"
		) AS t2
		ON t1.case_num = t2.case_num
		INNER JOIN (
			SELECT *
			FROM charges
			WHERE scan_date = \"#{today_date}\"
		) AS t3 
		ON t1.case_num = t3.case_num
		ORDER BY 
			t2.num_matches DESC,
			t2.defendant ASC
		;"
	].each{|r|
		row = r.map{|h| h[1]} # `r` is a hash, and `.map` converts each key=>value pair to an array. We get the second item in each of those converted arrays. This gives us an array with only the values
		f.puts(row.to_csv)
		p row
	}
}



