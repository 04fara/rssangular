class
	RSSANGULAR_EXECUTION

inherit

	WSF_ROUTED_EXECUTION

create
	make

feature

	setup_router
		local
			fs: WSF_FILE_SYSTEM_HANDLER
		do
			create fs.make_with_path ((create {EXECUTION_ENVIRONMENT}).current_working_path.extended ("www"))
			fs.set_directory_index (<<"index.html">>)
			fs.set_not_found_handler (agent ajax)
			router.handle ("/", fs, Void)
		end

	ajax (uri: READABLE_STRING_8; req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			input: STRING
			process_json: PROCESS_JSON
			db_manager: DB_MANAGER
		do
			if req.is_post_request_method and then attached req.http_referer as url then
				create db_manager.make
				req.set_raw_input_data_recorded (True)
				create input.make (req.content_length_value.as_integer_32)
				req.read_input_data_into (input)
				if url.tail (7).is_equal ("overall") then
					create process_json
					db_manager.perform_insert_query (process_json.insert_query (input))
				elseif url.tail (5).is_equal ("admin") then
					create process_json
					res.send (create_json_response (db_manager.perform_select_query (process_json.select_query (input))))
				else
					res.send (create_json_response (db_manager.select_from ("SELECT DISTINCT unitname as labs FROM forms")))
				end
			end
		end

	create_json_response (content: STRING): WSF_PAGE_RESPONSE
		do
			create Result.make
			Result.put_string (content)
			Result.header.add_content_type ({HTTP_MIME_TYPES}.application_json)
		end

end
