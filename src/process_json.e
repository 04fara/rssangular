class
	PROCESS_JSON

feature

	insert_query (json_content: STRING): STRING
		require
			json_content_valid: not json_content.is_empty
		local
			parser: JSON_PARSER
			l: STRING
			query0: STRING
			query1: ARRAYED_LIST [STRING]
		do
			query0 := "INSERT INTO forms VALUES ((SELECT COUNT(*) FROM forms) + 1, "
			create query1.make (0)
			create parser.make_with_string (json_content)
			parser.parse_content
			if parser.is_valid and then attached {JSON_OBJECT} parser.parsed_json_value as jtable and then attached jtable.current_keys as keys0 and then keys0.count > 0 then
				across
					keys0 as key
				loop
					if attached {JSON_STRING} jtable.item (key.item) as value then
						query0.append_string ("'" + value.unescaped_string_8 + "', ")
					elseif attached {JSON_ARRAY} jtable.item (key.item) as array then
						across
							array as object
						loop
							if attached {JSON_OBJECT} object.item as object1 and then attached object1.current_keys as keys1 then
								l := "INSERT INTO " + key.item.unescaped_string_8 + " VALUES ((SELECT COUNT(*) FROM forms), "
								across
									keys1 as key1
								loop
									if attached {JSON_STRING} object1.item (key1.item) as value then
										l.append ("'" + value.unescaped_string_8 + "', ")
									elseif attached {JSON_NUMBER} object1.item (key1.item) as value then
										l.append (value.integer_64_item.out + ", ")
									end
								end
								query1.extend (l)
							end
						end
					end
				end
			end
			Result := query0.head (query0.count - 2) + ");%N"
			across
				query1 as line
			loop
				Result.append (line.item.head (line.item.count - 2) + ");%N")
			end
		ensure
			Result_valid: not Result.is_empty
		end

	select_query (json_content: STRING): ARRAYED_LIST [ANY]
		require
			json_content_valid: not json_content.is_empty
		local
			parser: JSON_PARSER
		do
			create Result.make (0)
			create parser.make_with_string (json_content)
			parser.parse_content
			if parser.is_valid and then attached {JSON_OBJECT} parser.parsed_json_value as jtable and then attached jtable.current_keys as keys0 and then keys0.count > 0 then
				if attached {JSON_NUMBER} jtable.item (keys0.at (1)) as value then
					Result.extend (value.integer_64_item)
				end
				if attached {JSON_OBJECT} jtable.item (keys0.at (2)) as object and then attached object.current_keys as keys1 then
					across
						keys1 as key
					loop
						if attached {JSON_STRING} object.item (key.item) as value then
							Result.extend (value.unescaped_string_8)
						elseif attached {JSON_NUMBER} object.item (key.item) as value then
							Result.extend (value.integer_64_item)
						end
					end
				end
			end
		ensure
			Result_valid: not Result.is_empty
		end

end
