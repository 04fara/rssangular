class
	DB_MANAGER

create
	make

feature {NONE} -- Initialization

	make
		local
			file: RAW_FILE
		do
			create file.make_with_path (create {PATH}.make_from_string ("database.sqlite"))
			if file.exists then
				load_db
			else
				create_db
			end
		ensure
			db_closed: db.is_closed
		end

feature

	db: SQLITE_DATABASE

	load_db
		do
			create db.make_open_read ("database.sqlite")
			db.close
		ensure
			db_closed: db.is_closed
		end

	create_db
		local
			db_modify: SQLITE_MODIFY_STATEMENT
			query: STRING
		do
			create db.make_create_read_write ("database.sqlite")
			db.begin_transaction (true)
			query := "[
								
				CREATE TABLE IF NOT EXISTS `forms` (
				  `r_id` INTEGER PRIMARY KEY NOT NULL,
				  `unitname` MEDIUMTEXT NOT NULL,
				  `unithead` MEDIUMTEXT NOT NULL,
				  `innomail` MEDIUMTEXT NOT NULL,
				  `mail` MEDIUMTEXT NOT NULL,
				  `startdate` MEDIUMTEXT NOT NULL,
				  `enddate` MEDIUMTEXT NOT NULL,
				  `patents` MEDIUMTEXT NULL DEFAULT NULL,
				  `licensing` MEDIUMTEXT NULL DEFAULT NULL,
				  `additional` MEDIUMTEXT NULL DEFAULT NULL
				);
					
				CREATE TABLE IF NOT EXISTS `courses` (
				  `r_id` INTEGER NOT NULL,
				  `id` INTEGER NOT NULL,
				  `coname` MEDIUMTEXT NOT NULL,
				  `cosemester` MEDIUMTEXT NOT NULL,
				  `codegree` MEDIUMTEXT NOT NULL,
				  `conumber` INTEGER NOT NULL
				);
					
				CREATE TABLE IF NOT EXISTS `examinations` (
				  `r_id` INTEGER NOT NULL,
				  `id` INTEGER NOT NULL,
				  `exname` MEDIUMTEXT NOT NULL,
				  `exsemester` MEDIUMTEXT NOT NULL,
				  `exkind` MEDIUMTEXT NOT NULL,
				  `exnumber` INTEGER NOT NULL
				);
					
				CREATE TABLE IF NOT EXISTS `revised` (
				  `r_id` INTEGER NOT NULL,
				  `id` INTEGER NOT NULL,
				  `revname` MEDIUMTEXT NOT NULL,
				  `revnature` MEDIUMTEXT NOT NULL
				);
						
				CREATE TABLE IF NOT EXISTS `reports` (
				  `r_id` INTEGER NOT NULL,
				  `id` INTEGER NOT NULL,
				  `repname` MEDIUMTEXT NOT NULL,
				  `reptitle` MEDIUMTEXT NOT NULL,
				  `repplans` MEDIUMTEXT NOT NULL
				);
					
				CREATE TABLE IF NOT EXISTS `theses` (
				  `r_id` INTEGER NOT NULL,
				  `id` INTEGER NOT NULL,
				  `thename` MEDIUMTEXT NOT NULL,
				  `thedegree` MEDIUMTEXT NOT NULL,
				  `thesupervisor` MEDIUMTEXT NOT NULL,
				  `thecommittee` MEDIUMTEXT NOT NULL,
				  `theinstitution` MEDIUMTEXT NOT NULL,
				  `thetitle` MEDIUMTEXT NOT NULL
				);
					
				CREATE TABLE IF NOT EXISTS `grants` (
				  `r_id` INTEGER NOT NULL,
				  `id` INTEGER NOT NULL,
				  `gratitle` MEDIUMTEXT NOT NULL,
				  `graagency` MEDIUMTEXT NOT NULL,
				  `graperiod` MEDIUMTEXT NOT NULL,
				  `graamount` MEDIUMTEXT NOT NULL
				);
				
				CREATE TABLE IF NOT EXISTS `rprojects` (
				  `r_id` INTEGER NOT NULL,
				  `id` INTEGER NOT NULL,
				  `rptitle` MEDIUMTEXT NOT NULL,
				  `rpinno` MEDIUMTEXT NOT NULL,
				  `rpext` MEDIUMTEXT NOT NULL,
				  `rpstart` MEDIUMTEXT NOT NULL,
				  `rpend` MEDIUMTEXT NOT NULL,
				  `rpinvest` MEDIUMTEXT NOT NULL
				);
					
				CREATE TABLE IF NOT EXISTS `rcollab` (
				  `r_id` INTEGER NOT NULL,
				  `id` INTEGER NOT NULL,
				  `rccountry` MEDIUMTEXT NOT NULL,
				  `rcinstitution` MEDIUMTEXT NOT NULL,
				  `rcprincipal` MEDIUMTEXT NOT NULL,
				  `rcnature` MEDIUMTEXT NOT NULL
				);
						
				CREATE TABLE IF NOT EXISTS `conference` (
				  `r_id` INTEGER NOT NULL,
				  `id` INTEGER NOT NULL,
				  `confauthor` MEDIUMTEXT NOT NULL,
				  `confpubl` MEDIUMTEXT NOT NULL
				);
				
				CREATE TABLE IF NOT EXISTS `journal` (
				  `r_id` INTEGER NOT NULL,
				  `id` INTEGER NOT NULL,
				  `jauthor` MEDIUMTEXT NOT NULL,
				  `jpubl` MEDIUMTEXT NOT NULL
				);
				
				CREATE TABLE IF NOT EXISTS `awards` (
				  `r_id` INTEGER NOT NULL,
				  `id` INTEGER NOT NULL,
				  `awauthor` MEDIUMTEXT NOT NULL,
				  `awtitle` MEDIUMTEXT NOT NULL,
				  `awassoc` MEDIUMTEXT NOT NULL,
				  `awwording` MEDIUMTEXT NOT NULL,
				  `awdate` MEDIUMTEXT NOT NULL
				);
				
				CREATE TABLE IF NOT EXISTS `member` (
				  `r_id` INTEGER NOT NULL,
				  `id` INTEGER NOT NULL,
				  `memname` MEDIUMTEXT NOT NULL,
				  `memdate` MEDIUMTEXT NOT NULL
				);
				
				CREATE TABLE IF NOT EXISTS `prizes` (
				  `r_id` INTEGER NOT NULL,
				  `id` INTEGER NOT NULL,
				  `prrec` MEDIUMTEXT NOT NULL,
				  `prprize` MEDIUMTEXT NOT NULL,
				  `prinst` MEDIUMTEXT NOT NULL,
				  `prdate` MEDIUMTEXT NOT NULL
				);
				
				CREATE TABLE IF NOT EXISTS `icollab` (
				  `r_id` INTEGER NOT NULL,
				  `id` INTEGER NOT NULL,
				  `icomp` MEDIUMTEXT NOT NULL,
				  `inature` MEDIUMTEXT NOT NULL
				);
			]"
			create db_modify.make (query, db)
			db_modify.execute
			if db_modify.has_error then
				db.rollback
			else
				db.commit
			end
			db.close
		ensure
			db_closed: db.is_closed
		end

	perform_insert_query (query: STRING)
		require
			query_not_empty: not query.is_empty
		local
			db_insert: SQLITE_INSERT_STATEMENT
		do
			create db.make_open_read_write ("database.sqlite")
			create db_insert.make (query, db)
			db.begin_transaction (true)
			db_insert.execute
			if db_insert.has_error then
				db.rollback
			else
				db.commit
			end
			db.close
		ensure
			db_closed: db.is_closed
		end

	perform_select_query (params: ARRAYED_LIST [ANY]): STRING
		require
			params_valid: params.count /= 0
		local
			query: STRING
			queries: ARRAYED_LIST [TUPLE [a, b: STRING]]
			lab: STRING
			startdate: STRING
			enddate: STRING
		do
			create Result.make_empty
			inspect params.at (1).out.to_integer
			when 1 then
				query := "SELECT DISTINCT unitname AS 'Name of Unit', (SELECT COUNT(r_id) FROM forms WHERE unitname=f.unitname) AS 'Reports Count' FROM forms AS f ORDER BY unitname COLLATE NOCASE;"
				Result := select_from (query)
			when 2 then
				lab := params.at (2).out
				startdate := params.at (3).out
				enddate := params.at (4).out
				create queries.make (0)
				queries.extend ("forms", "SELECT unitname AS 'Name of Unit', unithead AS 'Head of Unit', innomail AS 'InnoMail', mail AS 'Mail', startdate AS 'From', enddate AS 'To' FROM forms AS f WHERE unitname='" + lab + "' AND CAST(substr(f.startdate, 7) as INTEGER)>=" + startdate + " AND CAST(substr(f.enddate, 7) as INTEGER)<=" + enddate + " ORDER BY r_id;")
				queries.extend ("patents", "SELECT patents FROM forms AS f WHERE unitname='" + lab + "' AND CAST(substr(f.startdate, 7) as INTEGER)>=" + startdate + " AND CAST(substr(f.enddate, 7) as INTEGER)<=" + enddate + " ORDER BY r_id;")
				queries.extend ("licensing", "SELECT licensing FROM forms AS f WHERE unitname='" + lab + "' AND CAST(substr(f.startdate, 7) as INTEGER)>=" + startdate + " AND CAST(substr(f.enddate, 7) as INTEGER)<=" + enddate + " ORDER BY r_id;")
				queries.extend ("additional", "SELECT additional FROM forms AS f WHERE unitname='" + lab + "' AND CAST(substr(f.startdate, 7) as INTEGER)>=" + startdate + " AND CAST(substr(f.enddate, 7) as INTEGER)<=" + enddate + " ORDER BY r_id;")
				queries.extend ("courses", "SELECT coname AS 'Name', cosemester AS 'Semester', codegree AS 'Degree', conumber AS 'Number' FROM courses AS c, forms AS f WHERE c.r_id=f.r_id AND unitname='" + lab + "' AND CAST(substr(f.startdate, 7) as INTEGER)>=" + startdate + " AND CAST(substr(f.enddate, 7) as INTEGER)<=" + enddate + " ORDER BY c.r_id;")
				queries.extend ("examinations", "SELECT exname AS 'Name', exsemester AS 'Semester', exkind AS 'Kind', exnumber AS 'Number' FROM examinations AS c, forms AS f WHERE c.r_id=f.r_id AND unitname='" + lab + "' AND CAST(substr(f.startdate, 7) as INTEGER)>=" + startdate + " AND CAST(substr(f.enddate, 7) as INTEGER)<=" + enddate + " ORDER BY c.r_id;")
				queries.extend ("revised", "SELECT revname AS 'Name', revnature AS 'Nature' FROM revised AS c, forms AS f WHERE c.r_id=f.r_id AND unitname='" + lab + "' AND CAST(substr(f.startdate, 7) as INTEGER)>=" + startdate + " AND CAST(substr(f.enddate, 7) as INTEGER)<=" + enddate + " ORDER BY c.r_id;")
				queries.extend ("reports", "SELECT repname AS 'Name', reptitle AS 'Title', repplans AS 'Plans' FROM reports AS c, forms AS f WHERE c.r_id=f.r_id AND unitname='" + lab + "' AND CAST(substr(f.startdate, 7) as INTEGER)>=" + startdate + " AND CAST(substr(f.enddate, 7) as INTEGER)<=" + enddate + " ORDER BY c.r_id;")
				queries.extend ("theses", "SELECT thename AS 'Name', thedegree AS 'Degree', thesupervisor AS 'Supervisor', thecommittee AS 'Committee', theinstitution AS 'Institution', thetitle AS 'Title' FROM theses AS c, forms AS f WHERE c.r_id=f.r_id AND unitname='" + lab + "' AND CAST(substr(f.startdate, 7) as INTEGER)>=" + startdate + " AND CAST(substr(f.enddate, 7) as INTEGER)<=" + enddate + " ORDER BY c.r_id;")
				queries.extend ("grants", "SELECT gratitle AS 'Title', graagency AS 'Agency', graperiod AS 'Period', graamount AS 'Amount' FROM grants AS c, forms AS f WHERE c.r_id=f.r_id AND unitname='" + lab + "' AND CAST(substr(f.startdate, 7) as INTEGER)>=" + startdate + " AND CAST(substr(f.enddate, 7) as INTEGER)<=" + enddate + " ORDER BY c.r_id;")
				queries.extend ("rprojects", "SELECT rptitle AS 'Title', rpinno AS 'Innopolis', rpext AS 'External', rpstart AS 'From', rpend AS 'To', rpinvest AS 'Investors' FROM rprojects AS c, forms AS f WHERE c.r_id=f.r_id AND unitname='" + lab + "' AND CAST(substr(f.startdate, 7) as INTEGER)>=" + startdate + " AND CAST(substr(f.enddate, 7) as INTEGER)<=" + enddate + " ORDER BY c.r_id;")
				queries.extend ("rcollab", "SELECT rccountry AS 'Country', rcinstitution AS 'Institution', rcprincipal AS 'Principal', rcnature AS 'Nature' FROM rcollab AS c, forms AS f WHERE c.r_id=f.r_id AND unitname='" + lab + "' AND CAST(substr(f.startdate, 7) as INTEGER)>=" + startdate + " AND CAST(substr(f.enddate, 7) as INTEGER)<=" + enddate + " ORDER BY c.r_id;")
				queries.extend ("conference", "SELECT confauthor AS 'Authors', confpubl AS 'Publication' FROM conference AS c, forms AS f WHERE c.r_id=f.r_id AND unitname='" + lab + "' AND CAST(substr(f.startdate, 7) as INTEGER)>=" + startdate + " AND CAST(substr(f.enddate, 7) as INTEGER)<=" + enddate + " ORDER BY c.r_id;")
				queries.extend ("journal", "SELECT jauthor AS 'Authors', jpubl AS 'Publication' FROM journal AS c, forms AS f WHERE c.r_id=f.r_id AND unitname='" + lab + "' AND CAST(substr(f.startdate, 7) as INTEGER)>=" + startdate + " AND CAST(substr(f.enddate, 7) as INTEGER)<=" + enddate + " ORDER BY c.r_id;")
				queries.extend ("awards", "SELECT awauthor AS 'Author', awtitle AS 'Title', awassoc AS 'Association', awwording AS 'Exact wording', awdate AS 'Date' FROM awards AS c, forms AS f WHERE c.r_id=f.r_id AND unitname='" + lab + "' AND CAST(substr(f.startdate, 7) as INTEGER)>=" + startdate + " AND CAST(substr(f.enddate, 7) as INTEGER)<=" + enddate + " ORDER BY c.r_id;")
				queries.extend ("member", "SELECT memname AS 'Name', memdate AS 'Date' FROM member AS c, forms AS f WHERE c.r_id=f.r_id AND unitname='" + lab + "' AND CAST(substr(f.startdate, 7) as INTEGER)>=" + startdate + " AND CAST(substr(f.enddate, 7) as INTEGER)<=" + enddate + " ORDER BY c.r_id;")
				queries.extend ("prizes", "SELECT prrec AS 'Recipient name', prprize AS 'Prize', prinst AS 'Institution', prdate AS 'Date' FROM prizes AS c, forms AS f WHERE c.r_id=f.r_id AND unitname='" + lab + "' AND CAST(substr(f.startdate, 7) as INTEGER)>=" + startdate + " AND CAST(substr(f.enddate, 7) as INTEGER)<=" + enddate + " ORDER BY c.r_id;")
				queries.extend ("icollab", "SELECT icomp AS 'Company', inature AS 'Nature' FROM icollab AS c, forms AS f WHERE c.r_id=f.r_id AND unitname='" + lab + "' AND CAST(substr(f.startdate, 7) as INTEGER)>=" + startdate + " AND CAST(substr(f.enddate, 7) as INTEGER)<=" + enddate + " ORDER BY c.r_id;")
				Result := select_from_queries (queries)
			when 3 then
				lab := params.at (2).out
				create queries.make (0)
				queries.extend ("conf", "SELECT confauthor AS Authors, confpubl AS Publication FROM conference AS c, forms AS f WHERE c.r_id=f.r_id AND f.unitname='" + lab + "' ORDER BY confpubl COLLATE NOCASE;")
				queries.extend ("jour", "SELECT jauthor AS Authors, jpubl AS Publication FROM journal AS j, forms AS f WHERE j.r_id=f.r_id AND f.unitname='" + lab + "' ORDER BY jpubl COLLATE NOCASE;")
				Result := select_from_queries (queries)
			when 4 then
				startdate := params.at (3).out
				enddate := params.at (4).out
				create queries.make (0)
				queries.extend ("conf", "SELECT confauthor AS Authors, confpubl AS Publication, f.unitname as Unit FROM conference AS c, forms AS f WHERE c.r_id=f.r_id AND CAST(substr(f.startdate, 7) as INTEGER)>=" + startdate + " AND CAST(substr(f.enddate, 7) as INTEGER)<=" + enddate + " ORDER BY confpubl COLLATE NOCASE;")
				queries.extend ("jour", "SELECT jauthor AS Authors, jpubl AS Publication, f.unitname as Unit FROM journal AS j, forms AS f WHERE j.r_id=f.r_id AND CAST(substr(f.startdate, 7) as INTEGER)>=" + startdate + " AND CAST(substr(f.enddate, 7) as INTEGER)<=" + enddate + " ORDER BY jpubl COLLATE NOCASE;")
				Result := select_from_queries (queries)
			when 5 then
				query := "SELECT DISTINCT unitname AS 'Name of Unit', (SELECT COUNT(r.r_id) FROM rcollab AS r, forms AS f1 WHERE r.r_id=f1.r_id and f1.unitname=f.unitname) AS 'Collaborations Count' FROM forms AS f ORDER BY unitname COLLATE NOCASE;"
				Result := select_from (query)
			when 6 then
				query := "SELECT DISTINCT unitname AS 'Name of Unit', (SELECT COUNT(r.id) FROM revised AS r, forms AS f1 WHERE r.r_id=f1.r_id and f1.unitname=f.unitname) AS 'Supervised Students Count' FROM forms AS f ORDER BY unitname COLLATE NOCASE;"
				Result := select_from (query)
			when 7 then
				lab := params.at (2).out
				startdate := params.at (3).out
				enddate := params.at (4).out
				query := "SELECT DISTINCT unitname AS 'Name of Unit', (SELECT GROUP_CONCAT(DISTINCT coname) FROM courses AS c, forms AS f1 WHERE c.r_id=f1.r_id and f1.unitname='" + lab + "' AND CAST(substr(f1.startdate, 7) as INTEGER)>=" + startdate + " AND CAST(substr(f1.enddate, 7) as INTEGER)<=" + enddate + ") AS 'Courses List' FROM forms AS f WHERE f.unitname='" + lab + "' ORDER BY unitname COLLATE NOCASE;"
				Result := select_from (query)
			end
		ensure
			Result_valid: not Result.is_empty
		end

	select_from_queries (queries: ARRAYED_LIST [TUPLE [a, b: STRING]]): STRING
		require
			queries_valid: not queries.is_empty
		do
			Result := "{%N%T"
			across
				queries as q
			loop
				Result.append (jsonify (q.item.a) + ": " + select_from (q.item.b) + ",")
			end
			Result.remove_tail (1)
			Result.append ("}%N")
		ensure
			Result_valid: not Result.is_empty
		end

	select_from (query: STRING): STRING
		require
			query_valid: not query.is_empty
		local
			db_query: SQLITE_QUERY_STATEMENT
			qcursor: SQLITE_STATEMENT_ITERATION_CURSOR
			row: SQLITE_RESULT_ROW
			labels: STRING
			data: STRING
			labels_set: BOOLEAN
			i: NATURAL
		do
			create db.make_open_read_write ("database.sqlite")
			create db_query.make (query, db)
			qcursor := db_query.execute_new
			if qcursor.after then
				Result := jsonify ("")
			else
				Result := "{%N%T"
				labels := jsonify ("labels") + ": ["
				data := jsonify ("values") + ": ["
				from
					qcursor.start
					labels_set := false
				until
					qcursor.after
				loop
					row := qcursor.item
					from
						i := 1
					until
						i > row.count
					loop
						if not labels_set then
							if i > 1 then
								labels.append (", ")
							end
							labels.append (jsonify (row.column_name (i)))
						end
						if i = 1 then
							data.append ("[")
						else
							data.append (", ")
						end
						if attached row.value (i) as v then
							data.append (jsonify (v.out))
						end
						i := i + 1
					end
					labels_set := true
					data.append ("]")
					qcursor.forth
					if not qcursor.after then
						data.append (", ")
					end
				end
				Result.append (labels + "],%N%T" + data + "]%N}")
			end
			db.close
		ensure
			Result_valid: not Result.is_empty
			db_closed: db.is_closed
		end

		jsonify (val: STRING): STRING
		require
			val_valid: not val.is_empty
		local
			ch: CHARACTER
		do
			ch := '"'
			Result := ch.out + val + ch.out
		ensure
			Result_valid: not Result.is_empty
		end

end
