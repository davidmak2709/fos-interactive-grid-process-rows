prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_200200 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2020.10.01'
,p_release=>'20.2.0.00.20'
,p_default_workspace_id=>89532025765818702
,p_default_application_id=>500
,p_default_id_offset=>0
,p_default_owner=>'OPP'
);
end;
/
 
prompt APPLICATION 500 - Laser*OPP
--
-- Application Export:
--   Application:     500
--   Name:            Laser*OPP
--   Date and Time:   13:21 Thursday December 28, 2023
--   Exported By:     DMAKOVAC
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 441585844511348477
--   Manifest End
--   Version:         20.2.0.00.20
--   Instance ID:     248285828437830
--

begin
  -- replace components
  wwv_flow_api.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/dynamic_action/com_fos_interactive_grid_process_rows
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(441585844511348477)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'COM.FOS.INTERACTIVE_GRID_PROCESS_ROWS'
,p_display_name=>'FOS - Interactive Grid - Process Rows'
,p_category=>'EXECUTE'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_javascript_file_urls=>'#PLUGIN_FILES#js/script#MIN#.js'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- =============================================================================',
'--',
'--  FOS = FOEX Open Source (fos.world), by FOEX GmbH, Austria (www.foex.at)',
'--',
'--  This plug-in executes PL/SQL code for each selected or filtered ',
'--  Interactive Grid row.',
'--',
'--  License: MIT',
'--',
'--  GitHub: https://github.com/foex-open-source/fos-interactive-grid-process-rows',
'--',
'-- =============================================================================',
'',
'c_plugin_name            constant varchar2(100) := ''FOS - Interactive Grid - Process Rows'';',
'c_pk_collection_name     constant varchar2(100) := ''FOS_IG_PK'';',
'c_bug_workaround_name    constant varchar2(100) := ''FOS_APEX_192_BUG_30665079_WORKAROUND'';',
'c_apex_192_identifier    constant number        := 20191004;',
'',
'function render',
'    ( p_dynamic_action apex_plugin.t_dynamic_action',
'    , p_plugin         apex_plugin.t_plugin',
'    )',
'return apex_plugin.t_dynamic_action_render_result',
'as',
'    l_return apex_plugin.t_dynamic_action_render_result;',
'',
'    l_mode                     p_dynamic_action.attribute_01%type := p_dynamic_action.attribute_01;',
'    l_items_to_submit          apex_t_varchar2                    := apex_string.split(p_dynamic_action.attribute_03, '','');',
'    l_refresh_selection        boolean                            := instr(p_dynamic_action.attribute_15, ''refresh-selection'')              > 0;',
'    l_refresh_grid             boolean                            := instr(p_dynamic_action.attribute_15, ''refresh-grid'')                   > 0;',
'    l_replace_on_client        boolean                            := instr(p_dynamic_action.attribute_15, ''client-substitutions'')           > 0;',
'    l_escape_message           boolean                            := instr(p_dynamic_action.attribute_15, ''escape-message'')                 > 0;',
'    l_remove_selection         boolean                            := instr(p_dynamic_action.attribute_15, ''remove-selection-after-process'') > 0;',
'',
'    -- fostr options',
'    l_dismiss_after_seconds    pls_integer  := nvl(cast(p_dynamic_action.attribute_12 as pls_integer), 0);',
'',
'    l_ajax_identifier          varchar2(1000)                     := apex_plugin.get_ajax_identifier;',
'    l_init_js_fn               varchar2(32767)                    := nvl(apex_plugin_util.replace_substitutions(p_dynamic_action.init_javascript_code), ''undefined'');',
'begin',
'',
'    -- debugging',
'    if apex_application.g_debug and substr(:DEBUG,6) >= 6',
'    then',
'        apex_plugin_util.debug_dynamic_action',
'          ( p_plugin         => p_plugin',
'          , p_dynamic_action => p_dynamic_action',
'          );',
'    end if;',
'',
'    apex_css.add_file',
'      ( p_name           => apex_plugin_util.replace_substitutions(''fostr#MIN#.css'')',
'      , p_directory      => p_plugin.file_prefix || ''css/''',
'      , p_skip_extension => true',
'      , p_key            => ''fostr''',
'      );',
'',
'    apex_javascript.add_library',
'      ( p_name           => apex_plugin_util.replace_substitutions(''fostr#MIN#.js'')',
'      , p_directory      => p_plugin.file_prefix || ''js/''',
'      , p_skip_extension => true',
'      , p_key            => ''fostr''',
'      );',
'',
'',
'    -- create a JS function call passing all settings as a JSON object',
'    --',
'    -- example:',
'    -- FOS.interactiveGrid.processRows({',
'    --    "action": {',
'    --        "affectedRegionId": "emp"',
'    --    }',
'    -- }, {',
'    --    "ajaxId": "fYS3t2c4SabnxV",',
'    --    "mode": "selection", // or "filtered"',
'    --    "itemsToSubmit": ["P1_ITEM"],',
'    --    "refreshSelection": true,',
'    --    "refreshGrid": false,',
'    --    "performSubstitutions": false,',
'    --    "escapeMessage": true,',
'    --    "dismissAfter": 0',
'    -- });',
'',
'    apex_json.initialize_clob_output;',
'    apex_json.open_object;',
'',
'    apex_json.write(''ajaxId''              , l_ajax_identifier);',
'    apex_json.write(''mode''                , l_mode);',
'    apex_json.write(''itemsToSubmit''       , l_items_to_submit);',
'    apex_json.write(''refreshSelection''    , l_refresh_selection);',
'    apex_json.write(''refreshGrid''         , l_refresh_grid);',
'    apex_json.write(''performSubstitutions'', l_replace_on_client);',
'    apex_json.write(''escapeMessage''       , l_escape_message);',
'    apex_json.write(''removeSelection''     , l_remove_selection);',
'    apex_json.write(''dismissAfter''        , l_dismiss_after_seconds * 1000);',
'    ',
'    apex_json.close_object;',
'',
'    l_return.javascript_function := ''function(){FOS.interactiveGrid.processRows(this, '' || apex_json.get_clob_output || '', ''|| l_init_js_fn || '');}'';',
'',
'    apex_json.free_output;',
'',
'    return l_return;',
'end render;',
'',
'/* ',
' * This helper function takes a stringified such as {"recordKeys":[["7839"],["7698"],["7782"],["7566"],["7788"]]}',
' * or, if there are more primary keys: {"recordKeys":[["7839","KING"],["7698","BLAKE"],["7782","CLARK"],["7566","JONES"]]}',
' * It then populates an APEX collection as such:',
' * c001 | c002',
' * -----+-----',
' * 7839 | KING',
' * 7698 | BLAKE',
' * 7782 | CLARK',
' */',
'procedure populate_pk_collection',
'  ( p_primary_keys_json   clob',
'  , p_primary_key_count   number',
'  )',
'as',
'    l_values          apex_json.t_values;',
'    l_elements        apex_t_varchar2;',
'    l_record_count    number;',
'',
'    l_current_pk_part varchar2(4000);',
'    l_seq_id          number;',
'begin',
'',
'    apex_json.parse',
'      ( p_values => l_values',
'      , p_source => p_primary_keys_json',
'      );',
'',
'    apex_collection.create_or_truncate_collection(c_pk_collection_name);',
'',
'    l_record_count := apex_json.get_count',
'                        ( p_values => l_values',
'                        , p_path   => ''recordKeys''',
'                        );',
'    -- for each primary key object. can contain multiple primary key columns',
'    for i in 1 .. l_record_count',
'    loop',
'',
'        l_elements := apex_json.get_t_varchar2',
'                        ( p_values => l_values',
'                        , p_path   => ''recordKeys[%d]''',
'                        , p0       => i',
'                        );',
'',
'        -- for each primary key column',
'        for j in 1 .. p_primary_key_count',
'        loop',
'',
'            l_current_pk_part := apex_json.get_varchar2',
'                                   ( p_values => l_values',
'                                   , p_path   => ''recordKeys[%d][%d]''',
'                                   , p0       => i',
'                                   , p1       => j',
'                                   );',
'',
'            if j = 1',
'            then',
'                l_seq_id := apex_collection.add_member',
'                              ( p_collection_name => c_pk_collection_name',
'                              , p_c001            => l_current_pk_part',
'                              );',
'            else',
'                apex_collection.update_member_attribute',
'                  ( p_collection_name => c_pk_collection_name',
'                  , p_seq             => l_seq_id',
'                  , p_attr_number     => j',
'                  , p_attr_value      => l_current_pk_part',
'                  );',
'            end if;',
'        end loop;',
'    end loop;',
'end populate_pk_collection;',
'',
'function ajax',
'  ( p_dynamic_action apex_plugin.t_dynamic_action',
'  , p_plugin         apex_plugin.t_plugin',
'  )',
'return apex_plugin.t_dynamic_action_ajax_result',
'as',
'',
'    l_affected_region_id varchar2(4000)                    := p_dynamic_action.affected_region_id;',
'',
'    l_is_selection_mode boolean                            := p_dynamic_action.attribute_01 = ''selection'';',
'    ',
'    l_items_to_return   apex_t_varchar2                    := apex_string.split(p_dynamic_action.attribute_04, '','');',
'',
'    l_plsql_code        p_dynamic_action.attribute_02%type := p_dynamic_action.attribute_02;',
'',
'    l_success_message   p_dynamic_action.attribute_05%type := p_dynamic_action.attribute_05;',
'    l_error_message     p_dynamic_action.attribute_06%type := p_dynamic_action.attribute_06;',
'    l_message           varchar2(32767);',
'    l_message_title     varchar2(32767);',
'    ',
'    l_escape_message    boolean                            := instr(p_dynamic_action.attribute_15, ''escape-message'')       > 0;',
'    l_replace_on_client boolean                            := instr(p_dynamic_action.attribute_15, ''client-substitutions'') > 0;',
'',
'    l_context           apex_exec.t_context;',
'',
'    --needed for the selection filter',
'    l_selected_records  clob                               := '''';',
'    l_filters           apex_exec.t_filters;',
'    l_primary_key_count number                             := 0;',
'    l_primary_key_cols  apex_t_varchar2                    := apex_t_varchar2();',
'    l_collection_cols   apex_t_varchar2                    := apex_t_varchar2();',
'    l_current_column    apex_exec.t_column;',
'    l_context_filter    varchar2(4000);',
'    ',
'    l_error_occurred    boolean                            := false;',
'    ',
'    l_plsql             varchar2(32000);',
'    ',
'    l_preference_data   varchar2(32000);',
'    l_report_id         varchar2(32000);',
'    l_report_type       varchar2(32000);',
'',
'    l_return apex_plugin.t_dynamic_action_ajax_result;',
'    ',
'    -- translation bug',
'    l_translation_bug_check integer;',
'    --',
'',
'    --',
'    -- We won''t escape serverside if we do it client side to avoid double escaping',
'    --',
'    function escape_html',
'      ( p_html                   in varchar2',
'      , p_escape_already_enabled in boolean',
'      ) return varchar2',
'    is ',
'    begin',
'        return case when p_escape_already_enabled then p_html else apex_escape.html(p_html) end;',
'    end escape_html;',
'',
'    --------------------------------------------------------------------------------',
'    -- dumps ajax parameters to debug output',
'    --------------------------------------------------------------------------------',
'    procedure log_ajax_parameters',
'    is',
'    begin',
'        if apex_application.g_debug',
'        then',
'            apex_debug.message(''---------------'');',
'            apex_debug.message(''AJAX Parameters'');',
'            apex_debug.message(''---------------'');',
'            apex_debug.message(''p_widget_name: %s'',apex_application.g_widget_name);',
'            apex_debug.message(''p_widget_action: %s'',apex_application.g_widget_action);',
'            apex_debug.message(''p_widget_action_mod: %s'',apex_application.g_widget_action_mod);',
'            apex_debug.message(''p_request: %s'',apex_application.g_request);',
'            apex_debug.message(''x01: %s'',apex_application.g_x01);',
'            --apex_debug.message(''x02: %s'',apex_application.g_x02);',
'            --apex_debug.message(''x03: %s'',apex_application.g_x03);',
'            --apex_debug.message(''x04: %s'',apex_application.g_x04);',
'            --apex_debug.message(''x05: %s'',apex_application.g_x05);',
'            --apex_debug.message(''x06: %s'',apex_application.g_x06);',
'            --apex_debug.message(''x07: %s'',apex_application.g_x07);',
'            --apex_debug.message(''x08: %s'',apex_application.g_x08);',
'            --apex_debug.message(''x09: %s'',apex_application.g_x09);',
'            --apex_debug.message(''x10: %s'',apex_application.g_x10);',
'            apex_debug.message(''f01: %s'',apex_util.table_to_string(apex_application.g_f01));',
'            apex_debug.message(''---------------'');',
'            apex_debug.message(''EOF Parameters'');',
'            apex_debug.message(''---------------'');',
'        end if;',
'    end log_ajax_parameters;',
'',
'begin',
'',
'    --debugging',
'    if apex_application.g_debug and substr(:DEBUG,6) >= 6 ',
'    then',
'        apex_plugin_util.debug_dynamic_action',
'          ( p_plugin         => p_plugin',
'          , p_dynamic_action => p_dynamic_action',
'          );',
'        log_ajax_parameters;',
'    end if;',
'',
'    apex_application.g_x01 := c_bug_workaround_name;',
'    ',
'    -- get the report id',
'    -- in 19.2 we cannot use the apex_ig.get_last_viewed_report_id',
'    -- so we have to read it directly from a preference ',
'    if wwv_flow_api.c_current = c_apex_192_identifier',
'    then',
'        l_preference_data := apex_util.get_preference',
'            ( p_preference => ''APEX_IG_'' || l_affected_region_id || ''_CURRENT_REPORT''',
'            );',
'',
'        if l_preference_data is not null',
'        then',
'            l_report_id   := substr( l_preference_data, 1, instr( l_preference_data, '':'' ) - 1);',
'            l_report_type := substr( l_preference_data, instr( l_preference_data, '':'' ) + 1);',
'        end if;',
'        ',
'    else',
'        -- we must use execute immediate in order to avoid compilation issues in 19.2',
'        l_plsql := q''#',
'            declare',
'                l_report_id number;',
'            begin',
'                l_report_id := apex_ig.get_last_viewed_report_id',
'                    ( p_page_id     => :b1',
'                    , p_region_id   => :b2 ',
'                    );',
'                 :b3 := l_report_id;',
'            end;',
'        #'';',
'        execute immediate l_plsql using in V(''APP_PAGE_ID''), l_affected_region_id, out l_report_id;',
'    end if;',
'',
'    -- when in selection mode, we must first compute the context filter, based on the records selected',
'    if l_is_selection_mode ',
'    then',
'        -- only opening the context to get the column and primary key information',
'        l_context := apex_region.open_query_context',
'                       ( p_page_id      => V(''APP_PAGE_ID'')',
'                       , p_region_id    => l_affected_region_id',
'                       , p_max_rows     => 0',
'                       , p_component_id => l_report_id    ',
'                       );                                    ',
'',
'        --rebuilding the primary key json',
'        for idx in 1 .. apex_application.g_f01.count',
'        loop',
'            l_selected_records := l_selected_records || apex_application.g_f01(idx);',
'        end loop;',
'',
'        -- looping through all columns to find the primary keys',
'        for idx in 1 .. apex_exec.get_column_count(l_context)',
'        loop',
'',
'            l_current_column := apex_exec.get_column',
'                                  ( p_context     => l_context',
'                                  , p_column_idx  => idx',
'                                  );',
'',
'              -- transaltion bug',
'            BEGIN',
'                SELECT',
'                CASE WHEN EXISTS(',
'                    SELECT ''x'' FROM APEX_APPL_PAGE_IG_COLUMNS x',
'                        WHERE x.application_id = V(''APP_ID'') ',
'                            AND x.page_id = V(''APP_PAGE_ID'') ',
'                            AND x.region_id = l_affected_region_id ',
'                            AND x.name = l_current_column.name ',
'                            AND UPPER(x.is_primary_key) = ''YES''',
'                    ) THEN',
'                        1',
'                    ELSE',
'                        0',
'                    END',
'                INTO l_translation_bug_check FROM dual;',
'            EXCEPTION WHEN OTHERS THEN',
'                l_translation_bug_check := 0;',
'            END;',
'            --',
'',
'            -- in case the column is a primary key, we add it to the array,',
'            -- as well as the c00x column it is mapped to',
'            if l_current_column.is_primary_key or l_translation_bug_check = 1',
'            then',
'                l_primary_key_count                          := l_primary_key_count + 1;',
'                l_primary_key_cols.extend(1);',
'                l_primary_key_cols(l_primary_key_cols.count) := l_current_column.name;',
'',
'                l_collection_cols.extend(1);',
'                l_collection_cols(l_collection_cols.count)   := ''c'' || lpad(l_collection_cols.count, 3, ''0'');',
'            end if;',
'',
'        end loop;',
'',
'        -- if there are no primary keys defines, raise an error',
'        if l_primary_key_cols.count = 0',
'        then',
'            raise_application_error(-20000, ''The Interactive Grid referenced by "'' || c_plugin_name || ''" must have a primary key defined.'');',
'        end if;',
'',
'        -- now construct the filter (where clause) to apply to the context later on',
'        l_context_filter := ''(#PRIMARY_KEY_COLUMNS#) in (select #COLLECTION_COLUMNS# from apex_collections where collection_name = ''''#COLLECTION_NAME#'''')'';',
'        l_context_filter := replace(l_context_filter, ''#PRIMARY_KEY_COLUMNS#'', apex_string.join(l_primary_key_cols, '',''));',
'        l_context_filter := replace(l_context_filter, ''#COLLECTION_COLUMNS#'', apex_string.join(l_collection_cols, '',''));',
'        l_context_filter := replace(l_context_filter, ''#COLLECTION_NAME#'', c_pk_collection_name);',
'',
'        -- adding the filter to the context',
'        apex_exec.add_filter',
'          ( p_filters         => l_filters',
'          , p_sql_expression  => l_context_filter',
'          );',
'',
'        -- populating the collection with the primary keys',
'        populate_pk_collection',
'          ( p_primary_keys_json   => l_selected_records',
'          , p_primary_key_count   => l_primary_key_cols.count',
'          );',
'',
'        apex_exec.close(l_context);',
'        commit; -- needed now in APEX 21.1',
'        ',
'    end if;',
'',
'    -- apply workaround for apex bug',
'    apex_application.g_x01 := c_bug_workaround_name;',
'',
'    -- open the context, with a possible filter if in selection mode',
'    l_context := apex_region.open_query_context',
'                   ( p_page_id             => V(''APP_PAGE_ID'')',
'                   , p_region_id           => l_affected_region_id',
'                   , p_additional_filters  => l_filters',
'                   , p_component_id        => l_report_id',
'                   );',
'',
'    -- resetting g_x01 to its original value as open_query_context is done parsing the columns',
'    apex_application.g_x01 := null;',
'    ',
'    -- for each row, execute the provided plsql code',
'    begin',
'        while apex_exec.next_row(l_context)',
'        loop',
'            apex_exec.execute_plsql(l_plsql_code);',
'        end loop;',
'    exception',
'        when others then',
'            l_message := nvl(apex_application.g_x01, l_error_message);',
'            ',
'            if not l_replace_on_client ',
'            then',
'                l_message := apex_plugin_util.replace_substitutions(l_message);',
'            end if;',
'            ',
'            if apex_application.g_x02 is not null ',
'            then',
'                if not l_replace_on_client ',
'                then',
'                    l_message_title := apex_plugin_util.replace_substitutions(apex_application.g_x02);',
'                end if;',
'            end if;',
'',
'            l_message := replace(l_message, ''#SQLCODE#'', escape_html(sqlcode, l_escape_message));',
'            l_message := replace(l_message, ''#SQLERRM#'', escape_html(sqlerrm, l_escape_message));',
'            l_message := replace(l_message, ''#SQLERRM_TEXT#'', escape_html(substr(sqlerrm, instr(sqlerrm, '':'')+1), l_escape_message));',
'            ',
'            rollback;',
'            l_error_occurred := true;',
'    end;',
'',
'    apex_exec.close(l_context);',
'',
'    -- remove the collection if in selection mode',
'    if l_is_selection_mode',
'    then',
'        apex_collection.delete_collection(c_pk_collection_name);',
'    end if;',
'',
'    -- construct the json response',
'    apex_json.open_object;',
'    ',
'    if not l_error_occurred ',
'    then',
'        apex_json.write(''status'', ''success'');',
'        l_message := nvl(apex_application.g_x01, l_success_message);',
'        ',
'        if not l_replace_on_client ',
'        then',
'            l_message := apex_plugin_util.replace_substitutions(l_message);',
'        end if;',
'        apex_json.write(''message'', l_message);',
'',
'        -- ',
'        -- the developer can optionally provide a message title and override the message type',
'        --',
'        if apex_application.g_x02 is not null ',
'        then',
'            if not l_replace_on_client ',
'            then',
'                l_message_title := apex_plugin_util.replace_substitutions(apex_application.g_x02);',
'            end if;',
'            apex_json.write(''messageTitle'', l_message_title);',
'        end if;',
'        ',
'        if apex_application.g_x03 is not null ',
'        then',
'            apex_json.write(''messageType'', apex_application.g_x03);',
'        end if;',
'',
'        if l_items_to_return.count > 0',
'        then',
'            apex_json.open_array(''itemsToReturn'');',
'',
'            for idx in 1 .. l_items_to_return.count',
'            loop',
'                apex_json.open_object;',
'                apex_json.write(''name'', l_items_to_return(idx));',
'                apex_json.write(''value'', V(l_items_to_return(idx)));',
'                apex_json.close_object;',
'            end loop;',
'',
'            apex_json.close_array;',
'        end if;',
'    else',
'        apex_json.write(''status''      , ''error'');',
'        apex_json.write(''message''     , l_message);',
'        apex_json.write(''messageTitle'', l_message_title);',
'    end if;',
'    ',
'    -- the developer can cancel following actions',
'    apex_json.write(''cancelActions'', upper(apex_application.g_x04) IN (''CANCEL'',''STOP'',''TRUE''));',
'',
'    -- the developer can fire an event if they desire',
'    apex_json.write(''eventName'', apex_application.g_x05);',
'            ',
'    apex_json.close_object;',
'',
'    return l_return;',
'exception',
'    when others',
'    then',
'        -- always ensure the context is closed, also in case of an error',
'        apex_exec.close(l_context);',
'        raise;',
'end ajax;'))
,p_api_version=>2
,p_render_function=>'render'
,p_ajax_function=>'ajax'
,p_standard_attributes=>'REGION:REQUIRED:STOP_EXECUTION_ON_ERROR:WAIT_FOR_RESULT:INIT_JAVASCRIPT_CODE'
,p_substitute_attributes=>false
,p_subscribe_plugin_settings=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>',
'    The <strong>FOS - Interactive Grid - Process Rows</strong> plug-in is used for bulk-processing rows of an interactive grid. It is a dynamic action that runs PL/SQL code on either only the selected rows or all filtered rows.',
'</p>',
'<p>',
'    You can pass page-items in and out of the PL/SQL code, display success and error messages, programmatically control success and error message content and behaviour, declaratively refresh the selected rows or the whole grid after completion, and i'
||'t also takes care of message substitutions and escaping.',
'</p>'))
,p_version_identifier=>'22.1.0'
,p_about_url=>'https://fos.world'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'// Settings for the FOS browser extension',
'@fos-auto-return-to-page',
'@fos-auto-open-files:js/script.js'))
,p_files_version=>397
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(729761082713330273)
,p_plugin_id=>wwv_flow_api.id(441585844511348477)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Action'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_default_value=>'selection'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'<p>The type of action to perform.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(729761429747330273)
,p_plugin_attribute_id=>wwv_flow_api.id(729761082713330273)
,p_display_sequence=>10
,p_display_value=>'Process Selected Rows'
,p_return_value=>'selection'
,p_help_text=>'<p>Process all rows which have been selected by the user</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(729761978484330274)
,p_plugin_attribute_id=>wwv_flow_api.id(729761082713330273)
,p_display_sequence=>20
,p_display_value=>'Process Filtered Rows'
,p_return_value=>'filtered'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Process all filtered rows.</p>',
'<p>Note that this refers to all filtered rows, meaning also the ones which have perhaps not been loaded into the page yet, due to pagination.</p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(729762453478330274)
,p_plugin_id=>wwv_flow_api.id(441585844511348477)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'PL/SQL Code'
,p_attribute_type=>'PLSQL'
,p_is_required=>true
,p_is_translatable=>false
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<pre>update emp',
'   set sal = sal + 100',
' where id = :ID;',
'<pre>'))
,p_help_text=>'<p>The PL/SQL code block to execute for each row.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(729762826229330274)
,p_plugin_id=>wwv_flow_api.id(441585844511348477)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Items to Submit'
,p_attribute_type=>'PAGE ITEMS'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'<p>Enter the page items to be set into session state when the process is initiated.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(729763237504330274)
,p_plugin_id=>wwv_flow_api.id(441585844511348477)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Items to Return'
,p_attribute_type=>'PAGE ITEMS'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'<p>Enter the page items to be returned from the server when the process is complete.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(729763700840330274)
,p_plugin_id=>wwv_flow_api.id(441585844511348477)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'Success Message'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Provide a success message which will be displayed as a success notification if the execution is completed successfully.</p>',
'<p>This message can be dynamically overridden in the PL/SQL Code block by assigning the new value to the apex_application.g_x01 global variable.</p>',
'<p>If no success message is provided, the success notification will not be shown.</p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(729764038664330274)
,p_plugin_id=>wwv_flow_api.id(441585844511348477)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_prompt=>'Error Message'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_default_value=>'#SQLERRM#'
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Provide an error message which will be displayed as an error notification if the execution raises an unhandled exception.</p>',
'<p>This message can be dynamically overridden in the PL/SQL Code block by assigning a new error message to the apex_application.g_x02 global variable.</p>',
'<p>If no error message is provided, the error notification will not be shown.</p>',
'<p>You can also use the #SQLCODE#, #SQLERRM# and #SQLERRM_TEXT# substitution strings for more detailed error information.</p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(729764451036330274)
,p_plugin_id=>wwv_flow_api.id(441585844511348477)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>12
,p_display_sequence=>160
,p_prompt=>'Auto dismiss after'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'5'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Number of seconds after which the notification should be automatically removed. Hovering or clicking the notification stops this event.',
'<br>',
'Default: <b>5</b>'))
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(729764883220330274)
,p_plugin_attribute_id=>wwv_flow_api.id(729764451036330274)
,p_display_sequence=>10
,p_display_value=>'5 seconds'
,p_return_value=>'5'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(729765340719330275)
,p_plugin_attribute_id=>wwv_flow_api.id(729764451036330274)
,p_display_sequence=>20
,p_display_value=>'10 seconds'
,p_return_value=>'10'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(729765848350330275)
,p_plugin_attribute_id=>wwv_flow_api.id(729764451036330274)
,p_display_sequence=>30
,p_display_value=>'No'
,p_return_value=>'0'
,p_help_text=>'Disable'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(729766363813330275)
,p_plugin_id=>wwv_flow_api.id(441585844511348477)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>15
,p_display_sequence=>150
,p_prompt=>'Extra Options'
,p_attribute_type=>'CHECKBOXES'
,p_is_required=>false
,p_default_value=>'escape-message'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'<p>Extra plug-in options.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(729766739611330275)
,p_plugin_attribute_id=>wwv_flow_api.id(729766363813330275)
,p_display_sequence=>10
,p_display_value=>'Refresh Selection After Processing'
,p_return_value=>'refresh-selection'
,p_help_text=>'<p>Refresh selected rows after processing.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(729767271508330275)
,p_plugin_attribute_id=>wwv_flow_api.id(729766363813330275)
,p_display_sequence=>20
,p_display_value=>'Refresh Grid After Processing'
,p_return_value=>'refresh-grid'
,p_help_text=>'<p>Refresh entire grid after processing.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(729767793506330275)
,p_plugin_attribute_id=>wwv_flow_api.id(729766363813330275)
,p_display_sequence=>30
,p_display_value=>'Replace Message Substitutions Client-side'
,p_return_value=>'client-substitutions'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>By default, item substitutions in success and error messages will be performed server-side, with session-state values, right after the processing has finished in the AJAX call.</p>',
'<p>This option enables you to override this, and perform the substitutions on the client, after the AJAX response has arrived, but before the notification is shown.</p>',
'',
'<p>Server-side substitutions are usually the desired method, as they are sure to use the latest session-state values, but can also replace application items, which the client does not have access to. Client-side substitutions are desired when substit'
||'uting for an item whose value exists on the client, but has not yet propagated to session-state.</p>'))
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(729768259217330275)
,p_plugin_attribute_id=>wwv_flow_api.id(729766363813330275)
,p_display_sequence=>40
,p_display_value=>'Escape Special Characters in Messages'
,p_return_value=>'escape-message'
,p_help_text=>'<p>Enable this option to escape any HTML tags in the success or error message. This should remain turned on by default to avoid any possibility of a cross-site-scripting attack. If however you do need to display HTML in a notification, you can turn t'
||'his setting off, but escape individual page items via the <code>&P1_ITEM!HTML.</code> syntax.</p>'
);
end;
/
begin
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(729768791429330276)
,p_plugin_attribute_id=>wwv_flow_api.id(729766363813330275)
,p_display_sequence=>50
,p_display_value=>'Remove Selection After Processing'
,p_return_value=>'remove-selection-after-process'
,p_help_text=>'<p>Deselect every row in the Interactive Grid after the process successfully executed.</p>'
);
wwv_flow_api.create_plugin_std_attribute(
 p_id=>wwv_flow_api.id(729775981371330287)
,p_plugin_id=>wwv_flow_api.id(441585844511348477)
,p_name=>'INIT_JAVASCRIPT_CODE'
,p_is_required=>false
,p_depending_on_has_to_exist=>true
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<pre>function(config){',
'    config.refreshGrid = true;',
'}',
'</pre>'))
,p_help_text=>'Javascript function which allows you to override any settings right before the dynamic action is invoked.'
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A0A0A094E6F7465730A09092A206162736F6C757465206C65667420616E642072696768742076616C7565732073686F756C64206E6F7720626520706C61636573206F6E2074686520636F6E7461696E657220656C656D656E742C206E6F7420746865';
wwv_flow_api.g_varchar2_table(2) := '20696E646976696475616C206E6F74696669636174696F6E730A0A2A2F0A2F2A2A0A202A204669786573206C696E6B207374796C696E6720696E206572726F72730A202A2F0A202E666F732D416C6572742D2D706167652E666F732D416C6572742D2D77';
wwv_flow_api.g_varchar2_table(3) := '61726E696E6720612C0A202E666F732D416C6572742D2D706167652E666F732D416C6572742D2D64616E6765722061207B0A202020636F6C6F723A20696E68657269743B0A202020746578742D6465636F726174696F6E3A20756E6465726C696E653B0A';
wwv_flow_api.g_varchar2_table(4) := '207D0A202F2A2A0A20202A20436F6C6F72697A6564204261636B67726F756E640A20202A2F0A202E666F732D416C6572742D2D686F72697A6F6E74616C207B0A202020626F726465722D7261646975733A203270783B0A207D0A202E666F732D416C6572';
wwv_flow_api.g_varchar2_table(5) := '742D69636F6E202E742D49636F6E207B0A202020636F6C6F723A20234646463B0A207D0A202F2A2A0A2020202A204D6F6469666965723A205761726E696E670A2020202A2F0A202E666F732D416C6572742D2D7761726E696E67202E666F732D416C6572';
wwv_flow_api.g_varchar2_table(6) := '742D69636F6E202E742D49636F6E207B0A202020636F6C6F723A20236662636634613B20200A207D0A202E666F732D416C6572742D2D7761726E696E672E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D69636F6E20';
wwv_flow_api.g_varchar2_table(7) := '7B0A2020206261636B67726F756E642D636F6C6F723A2072676261283235312C203230372C2037342C20302E3135293B0A207D0A202F2A2A0A2020202A204D6F6469666965723A20537563636573730A2020202A2F0A202E666F732D416C6572742D2D73';
wwv_flow_api.g_varchar2_table(8) := '756363657373202E666F732D416C6572742D69636F6E202E742D49636F6E207B0A202020636F6C6F723A20766172282D2D612D70616C657474652D737563636573732C2023334241413243293B0A207D0A202E666F732D416C6572742D2D737563636573';
wwv_flow_api.g_varchar2_table(9) := '732E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D69636F6E207B0A2020206261636B67726F756E642D636F6C6F723A20726762612835392C203137302C2034342C20302E3135293B0A207D0A202F2A2A0A2020202A';
wwv_flow_api.g_varchar2_table(10) := '204D6F6469666965723A20496E666F726D6174696F6E0A2020202A2F0A202E666F732D416C6572742D2D696E666F202E666F732D416C6572742D69636F6E202E742D49636F6E207B0A202020636F6C6F723A20766172282D2D612D70616C657474652D69';
wwv_flow_api.g_varchar2_table(11) := '6E666F2C2023303037366466293B0A207D0A202E666F732D416C6572742D2D696E666F2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D69636F6E207B0A2020206261636B67726F756E642D636F6C6F723A20726762';
wwv_flow_api.g_varchar2_table(12) := '6128302C203131382C203232332C20302E3135293B0A207D0A202F2A2A0A2020202A204D6F6469666965723A2044616E6765720A2020202A2F0A202E666F732D416C6572742D2D64616E676572202E666F732D416C6572742D69636F6E202E742D49636F';
wwv_flow_api.g_varchar2_table(13) := '6E207B0A202020636F6C6F723A20766172282D2D612D70616C657474652D64616E6765722C2023663434333336293B0A207D0A202E666F732D416C6572742D2D64616E6765722E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C';
wwv_flow_api.g_varchar2_table(14) := '6572742D69636F6E207B0A2020206261636B67726F756E642D636F6C6F723A2072676261283234342C2036372C2035342C20302E3135293B0A207D0A202E666F732D416C6572742D2D686F72697A6F6E74616C207B0A2020206261636B67726F756E642D';
wwv_flow_api.g_varchar2_table(15) := '636F6C6F723A20236666666666663B0A202020636F6C6F723A20233236323632363B0A207D0A202F2A0A202E666F732D416C6572742D2D64616E6765727B0A2020204062673A206C69676874656E2840675F44616E6765722D42472C20343025293B0A20';
wwv_flow_api.g_varchar2_table(16) := '20206261636B67726F756E642D636F6C6F723A204062673B0A202020636F6C6F723A206661646528636F6E7472617374284062672C2064657361747572617465286461726B656E284062672C202031303025292C2031303025292C206465736174757261';
wwv_flow_api.g_varchar2_table(17) := '7465286C69676874656E284062672C202031303025292C2035302529292C2031303025293B0A207D0A202E666F732D416C6572742D2D696E666F207B0A2020204062673A206C69676874656E2840675F496E666F2D42472C20353525293B0A2020206261';
wwv_flow_api.g_varchar2_table(18) := '636B67726F756E642D636F6C6F723A204062673B0A202020636F6C6F723A206661646528636F6E7472617374284062672C2064657361747572617465286461726B656E284062672C202031303025292C2031303025292C2064657361747572617465286C';
wwv_flow_api.g_varchar2_table(19) := '69676874656E284062672C202031303025292C2035302529292C2031303025293B0A207D0A202A2F0A202E666F732D416C6572742D2D706167652E666F732D416C6572742D2D73756363657373207B0A2020206261636B67726F756E642D636F6C6F723A';
wwv_flow_api.g_varchar2_table(20) := '20766172282D2D612D70616C657474652D737563636573732C2023334241413243293B3B0A202020636F6C6F723A20766172282D2D612D70616C657474652D737563636573732D636F6E74726173742C2023464646293B0A207D0A202E666F732D416C65';
wwv_flow_api.g_varchar2_table(21) := '72742D2D706167652E666F732D416C6572742D2D73756363657373202E666F732D416C6572742D69636F6E207B0A2020206261636B67726F756E642D636F6C6F723A207472616E73706172656E743B0A202020636F6C6F723A20234646463B0A207D0A20';
wwv_flow_api.g_varchar2_table(22) := '2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D73756363657373202E666F732D416C6572742D69636F6E202E742D49636F6E207B0A202020636F6C6F723A20696E68657269743B0A207D0A202E666F732D416C6572742D2D706167';
wwv_flow_api.g_varchar2_table(23) := '652E666F732D416C6572742D2D73756363657373202E742D427574746F6E2D2D636C6F7365416C657274207B0A202020636F6C6F723A20234646462021696D706F7274616E743B0A207D0A202E666F732D416C6572742D2D706167652E666F732D416C65';
wwv_flow_api.g_varchar2_table(24) := '72742D2D7761726E696E67207B0A2020206261636B67726F756E642D636F6C6F723A20236662636634613B0A202020636F6C6F723A2020233434333430323B0A207D0A202E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E';
wwv_flow_api.g_varchar2_table(25) := '696E67202E666F732D416C6572742D69636F6E207B0A2020206261636B67726F756E642D636F6C6F723A207472616E73706172656E743B0A202020636F6C6F723A20233434333430323B0A207D0A202E666F732D416C6572742D2D706167652E666F732D';
wwv_flow_api.g_varchar2_table(26) := '416C6572742D2D7761726E696E67202E666F732D416C6572742D69636F6E202E742D49636F6E207B0A202020636F6C6F723A20696E68657269743B0A207D0A202E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E6720';
wwv_flow_api.g_varchar2_table(27) := '2E742D427574746F6E2D2D636C6F7365416C657274207B0A202020636F6C6F723A20234646462021696D706F7274616E743B0A207D0A202E666F732D416C6572742D2D706167652E666F732D416C6572742D2D696E666F207B0A2020206261636B67726F';
wwv_flow_api.g_varchar2_table(28) := '756E642D636F6C6F723A20766172282D2D612D70616C657474652D696E666F2C2023303037366466293B0A202020636F6C6F723A20766172282D2D612D70616C657474652D696E666F2D636F6E74726173742C2023464646293B0A207D0A202E666F732D';
wwv_flow_api.g_varchar2_table(29) := '416C6572742D2D706167652E666F732D416C6572742D2D696E666F202E666F732D416C6572742D69636F6E207B0A2020206261636B67726F756E642D636F6C6F723A207472616E73706172656E743B0A202020636F6C6F723A20234646463B0A207D0A20';
wwv_flow_api.g_varchar2_table(30) := '2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D696E666F202E666F732D416C6572742D69636F6E202E742D49636F6E207B0A202020636F6C6F723A20696E68657269743B0A207D0A202E666F732D416C6572742D2D706167652E66';
wwv_flow_api.g_varchar2_table(31) := '6F732D416C6572742D2D696E666F202E742D427574746F6E2D2D636C6F7365416C657274207B0A202020636F6C6F723A20234646462021696D706F7274616E743B0A207D0A202E666F732D416C6572742D2D706167652E666F732D416C6572742D2D6461';
wwv_flow_api.g_varchar2_table(32) := '6E676572207B0A2020206261636B67726F756E642D636F6C6F723A20766172282D2D612D70616C657474652D64616E6765722C2023663434333336293B0A202020636F6C6F723A20766172282D2D612D70616C657474652D64616E6765722D636F6E7472';
wwv_flow_api.g_varchar2_table(33) := '6173742C2023464646293B0A207D0A202E666F732D416C6572742D2D706167652E666F732D416C6572742D2D64616E676572202E666F732D416C6572742D69636F6E207B0A2020206261636B67726F756E642D636F6C6F723A207472616E73706172656E';
wwv_flow_api.g_varchar2_table(34) := '743B0A202020636F6C6F723A20234646463B0A207D0A202E666F732D416C6572742D2D706167652E666F732D416C6572742D2D64616E676572202E666F732D416C6572742D69636F6E202E742D49636F6E207B0A202020636F6C6F723A20696E68657269';
wwv_flow_api.g_varchar2_table(35) := '743B0A207D0A202E666F732D416C6572742D2D706167652E666F732D416C6572742D2D64616E676572202E742D427574746F6E2D2D636C6F7365416C657274207B0A202020636F6C6F723A20234646462021696D706F7274616E743B0A207D0A202F2A20';
wwv_flow_api.g_varchar2_table(36) := '486F72697A6F6E74616C20416C657274203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F0A202E666F73';
wwv_flow_api.g_varchar2_table(37) := '2D416C6572742D2D686F72697A6F6E74616C207B0A2020206D617267696E2D626F74746F6D3A20312E3672656D3B0A202020706F736974696F6E3A2072656C61746976653B0A207D0A202E666F732D416C6572742D2D686F72697A6F6E74616C202E666F';
wwv_flow_api.g_varchar2_table(38) := '732D416C6572742D77726170207B0A202020646973706C61793A20666C65783B0A202020666C65782D646972656374696F6E3A20726F773B0A207D0A202E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D69636F6E20';
wwv_flow_api.g_varchar2_table(39) := '7B0A20202070616464696E673A203020313670783B0A202020666C65782D736872696E6B3A20303B0A202020646973706C61793A20666C65783B0A202020616C69676E2D6974656D733A2063656E7465723B0A207D0A202E666F732D416C6572742D2D68';
wwv_flow_api.g_varchar2_table(40) := '6F72697A6F6E74616C202E666F732D416C6572742D636F6E74656E74207B0A20202070616464696E673A20313670783B0A202020666C65783A203120303B0A202020646973706C61793A20666C65783B0A202020666C65782D646972656374696F6E3A20';
wwv_flow_api.g_varchar2_table(41) := '636F6C756D6E3B0A2020206A7573746966792D636F6E74656E743A2063656E7465723B0A207D0A202E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D627574746F6E73207B0A202020666C65782D736872696E6B3A20';
wwv_flow_api.g_varchar2_table(42) := '303B0A202020746578742D616C69676E3A2072696768743B0A20202077686974652D73706163653A206E6F777261703B0A20202070616464696E672D72696768743A20312E3672656D3B0A202020646973706C61793A20666C65783B0A202020616C6967';
wwv_flow_api.g_varchar2_table(43) := '6E2D6974656D733A2063656E7465723B0A207D0A202E752D52544C202E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D627574746F6E73207B0A20202070616464696E672D72696768743A20303B0A20202070616464';
wwv_flow_api.g_varchar2_table(44) := '696E672D6C6566743A20312E3672656D3B0A207D0A202E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D627574746F6E733A656D707479207B0A202020646973706C61793A206E6F6E653B0A207D0A202E666F732D41';
wwv_flow_api.g_varchar2_table(45) := '6C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D7469746C65207B0A202020666F6E742D73697A653A203272656D3B0A2020206C696E652D6865696768743A20322E3472656D3B0A2020206D617267696E2D626F74746F6D3A20303B';
wwv_flow_api.g_varchar2_table(46) := '0A207D0A202E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D626F64793A656D707479207B0A202020646973706C61793A206E6F6E653B0A207D0A202E666F732D416C6572742D2D686F72697A6F6E74616C202E666F';
wwv_flow_api.g_varchar2_table(47) := '732D416C6572742D69636F6E202E742D49636F6E207B0A202020666F6E742D73697A653A20333270783B0A20202077696474683A20333270783B0A202020746578742D616C69676E3A2063656E7465723B0A2020206865696768743A20333270783B0A20';
wwv_flow_api.g_varchar2_table(48) := '20206C696E652D6865696768743A20313B0A207D0A202F2A203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D20';
wwv_flow_api.g_varchar2_table(49) := '436F6D6D6F6E2050726F70657274696573203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F0A202E666F';
wwv_flow_api.g_varchar2_table(50) := '732D416C6572742D2D686F72697A6F6E74616C207B0A202020626F726465723A2031707820736F6C6964207267626128302C20302C20302C20302E31293B0A202020626F782D736861646F773A20302032707820347078202D327078207267626128302C';
wwv_flow_api.g_varchar2_table(51) := '20302C20302C20302E303735293B0A207D0A202E666F732D416C6572742D2D6E6F49636F6E2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D69636F6E207B0A202020646973706C61793A206E6F6E652021696D706F';
wwv_flow_api.g_varchar2_table(52) := '7274616E743B0A207D0A202E666F732D416C6572742D2D6E6F49636F6E202E666F732D416C6572742D69636F6E202E742D49636F6E207B0A202020646973706C61793A206E6F6E653B0A207D0A202E742D426F64792D616C657274207B0A2020206D6172';
wwv_flow_api.g_varchar2_table(53) := '67696E3A20303B0A207D0A202E742D426F64792D616C657274202E666F732D416C657274207B0A2020206D617267696E2D626F74746F6D3A20303B0A207D0A202F2A2050616765204E6F74696669636174696F6E202853756363657373206F72204D6573';
wwv_flow_api.g_varchar2_table(54) := '7361676529203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F0A202E666F732D416C6572742D2D706167';
wwv_flow_api.g_varchar2_table(55) := '65207B0A2020207472616E736974696F6E3A20302E327320656173652D6F75743B0A2020206D61782D77696474683A2036343070783B0A2020206D696E2D77696474683A2033323070783B0A2020202F2A706F736974696F6E3A2066697865643B20746F';
wwv_flow_api.g_varchar2_table(56) := '703A20312E3672656D3B2072696768743A20312E3672656D3B2A2F0A2020207A2D696E6465783A20313030303B0A202020626F726465722D77696474683A20303B0A202020626F782D736861646F773A20302030203020302E3172656D20726762612830';
wwv_flow_api.g_varchar2_table(57) := '2C20302C20302C20302E312920696E7365742C20302033707820397078202D327078207267626128302C20302C20302C20302E31293B0A2020202F2A20466F72207665727920736D616C6C2073637265656E732C2066697420746865206D657373616765';
wwv_flow_api.g_varchar2_table(58) := '20746F2074686520746F70206F66207468652073637265656E202A2F0A2020202F2A2053657420426F726465722052616469757320746F2030206173206D657373616765206578697374732077697468696E20636F6E74656E74202A2F0A2020202F2A20';
wwv_flow_api.g_varchar2_table(59) := '50616765204C6576656C205761726E696E6720616E64204572726F7273203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D';
wwv_flow_api.g_varchar2_table(60) := '3D3D3D3D202A2F0A2020202F2A205363726F6C6C62617273202A2F0A207D0A202E666F732D416C6572742D2D70616765202E666F732D416C6572742D627574746F6E73207B0A20202070616464696E672D72696768743A20303B0A207D0A202E666F732D';
wwv_flow_api.g_varchar2_table(61) := '416C6572742D2D70616765202E666F732D416C6572742D69636F6E207B0A20202070616464696E672D6C6566743A20312E3672656D3B0A20202070616464696E672D72696768743A203870783B0A207D0A202E752D52544C202E666F732D416C6572742D';
wwv_flow_api.g_varchar2_table(62) := '2D70616765202E666F732D416C6572742D69636F6E207B0A20202070616464696E672D6C6566743A203870783B0A20202070616464696E672D72696768743A20312E3672656D3B0A207D0A202E666F732D416C6572742D2D70616765202E666F732D416C';
wwv_flow_api.g_varchar2_table(63) := '6572742D69636F6E202E742D49636F6E207B0A202020666F6E742D73697A653A20323470783B0A20202077696474683A20323470783B0A2020206865696768743A20323470783B0A2020206C696E652D6865696768743A20313B0A207D0A202E666F732D';
wwv_flow_api.g_varchar2_table(64) := '416C6572742D2D70616765202E666F732D416C6572742D626F6479207B0A20202070616464696E672D626F74746F6D3A203870783B0A20202070616464696E672D746F703A203870783B0A202020666F6E742D73697A653A20312E3672656D3B0A202020';
wwv_flow_api.g_varchar2_table(65) := '666F6E742D7765696768743A20626F6C643B0A207D0A202E666F732D416C6572742D2D70616765202E666F732D416C6572742D636F6E74656E74207B0A20202070616464696E673A203870783B0A207D0A202E666F732D416C6572742D2D70616765202E';
wwv_flow_api.g_varchar2_table(66) := '742D427574746F6E2D2D636C6F7365416C657274207B0A202020706F736974696F6E3A206162736F6C7574653B0A20202072696768743A202D3870783B0A202020746F703A202D3870783B0A20202070616464696E673A203470783B0A2020206D696E2D';
wwv_flow_api.g_varchar2_table(67) := '77696474683A20303B0A2020206261636B67726F756E642D636F6C6F723A20233030302021696D706F7274616E743B0A202020636F6C6F723A20234646462021696D706F7274616E743B0A202020626F782D736861646F773A2030203020302031707820';
wwv_flow_api.g_varchar2_table(68) := '72676261283235352C203235352C203235352C20302E3235292021696D706F7274616E743B0A202020626F726465722D7261646975733A20323470783B0A2020207472616E736974696F6E3A202D7765626B69742D7472616E73666F726D20302E313235';
wwv_flow_api.g_varchar2_table(69) := '7320656173653B0A2020207472616E736974696F6E3A207472616E73666F726D20302E3132357320656173653B0A2020207472616E736974696F6E3A207472616E73666F726D20302E3132357320656173652C202D7765626B69742D7472616E73666F72';
wwv_flow_api.g_varchar2_table(70) := '6D20302E3132357320656173653B0A207D0A202E752D52544C202E666F732D416C6572742D2D70616765202E742D427574746F6E2D2D636C6F7365416C657274207B0A20202072696768743A206175746F3B0A2020206C6566743A202D3870783B0A207D';
wwv_flow_api.g_varchar2_table(71) := '0A202E666F732D416C6572742D2D70616765202E742D427574746F6E2D2D636C6F7365416C6572743A686F766572207B0A2020202D7765626B69742D7472616E73666F726D3A207363616C6528312E3135293B0A2020207472616E73666F726D3A207363';
wwv_flow_api.g_varchar2_table(72) := '616C6528312E3135293B0A207D0A202E666F732D416C6572742D2D70616765202E742D427574746F6E2D2D636C6F7365416C6572743A616374697665207B0A2020202D7765626B69742D7472616E73666F726D3A207363616C6528302E3835293B0A2020';
wwv_flow_api.g_varchar2_table(73) := '207472616E73666F726D3A207363616C6528302E3835293B0A207D0A202F2A2E752D52544C202E666F732D416C6572742D2D70616765207B2072696768743A206175746F3B206C6566743A20312E3672656D3B207D2A2F0A202E666F732D416C6572742D';
wwv_flow_api.g_varchar2_table(74) := '2D706167652E666F732D416C657274207B0A202020626F726465722D7261646975733A20302E3472656D3B0A207D0A202E666F732D416C6572742D2D70616765202E666F732D416C6572742D7469746C65207B0A20202070616464696E673A2038707820';
wwv_flow_api.g_varchar2_table(75) := '303B0A207D0A202E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E67202E612D4E6F74696669636174696F6E207B0A2020206D617267696E2D72696768743A203870783B0A207D0A202E666F732D416C6572742D2D70';
wwv_flow_api.g_varchar2_table(76) := '6167652E666F732D416C6572742D2D7761726E696E67202E612D4E6F74696669636174696F6E2D7469746C65207B0A202020666F6E742D73697A653A20312E3472656D3B0A2020206C696E652D6865696768743A203272656D3B0A202020666F6E742D77';
wwv_flow_api.g_varchar2_table(77) := '65696768743A203730303B0A2020206D617267696E3A20303B0A207D0A202E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E67202E612D4E6F74696669636174696F6E2D6C697374207B0A2020206D61782D68656967';
wwv_flow_api.g_varchar2_table(78) := '68743A2031323870783B0A207D0A202E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6C697374207B0A2020206D61782D6865696768743A20393670783B0A2020206F766572666C6F773A206175746F3B0A207D0A202E';
wwv_flow_api.g_varchar2_table(79) := '666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6C696E6B3A686F766572207B0A202020746578742D6465636F726174696F6E3A20756E6465726C696E653B0A207D0A202E666F732D416C6572742D2D70616765203A3A2D';
wwv_flow_api.g_varchar2_table(80) := '7765626B69742D7363726F6C6C626172207B0A20202077696474683A203870783B0A2020206865696768743A203870783B0A207D0A202E666F732D416C6572742D2D70616765203A3A2D7765626B69742D7363726F6C6C6261722D7468756D62207B0A20';
wwv_flow_api.g_varchar2_table(81) := '20206261636B67726F756E642D636F6C6F723A207267626128302C20302C20302C20302E3235293B0A207D0A202E666F732D416C6572742D2D70616765203A3A2D7765626B69742D7363726F6C6C6261722D747261636B207B0A2020206261636B67726F';
wwv_flow_api.g_varchar2_table(82) := '756E642D636F6C6F723A207267626128302C20302C20302C20302E3035293B0A207D0A202E666F732D416C6572742D2D70616765202E666F732D416C6572742D7469746C65207B0A202020646973706C61793A20626C6F636B3B0A202020666F6E742D77';
wwv_flow_api.g_varchar2_table(83) := '65696768743A203730303B0A202020666F6E742D73697A653A20312E3872656D3B0A2020206D617267696E2D626F74746F6D3A20303B0A2020206D617267696E2D72696768743A20313670783B0A207D0A202E666F732D416C6572742D2D70616765202E';
wwv_flow_api.g_varchar2_table(84) := '666F732D416C6572742D626F6479207B0A2020206D617267696E2D72696768743A20313670783B0A207D0A202E752D52544C202E666F732D416C6572742D2D70616765202E666F732D416C6572742D7469746C65207B0A2020206D617267696E2D726967';
wwv_flow_api.g_varchar2_table(85) := '68743A20303B0A2020206D617267696E2D6C6566743A20313670783B0A207D0A202E752D52544C202E666F732D416C6572742D2D70616765202E666F732D416C6572742D626F6479207B0A2020206D617267696E2D72696768743A20303B0A2020206D61';
wwv_flow_api.g_varchar2_table(86) := '7267696E2D6C6566743A20313670783B0A207D0A202E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6C697374207B0A2020206D617267696E3A203470782030203020303B0A20202070616464696E673A20303B0A2020';
wwv_flow_api.g_varchar2_table(87) := '206C6973742D7374796C653A206E6F6E653B0A207D0A202E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6974656D207B0A20202070616464696E672D6C6566743A20323070783B0A202020706F736974696F6E3A2072';
wwv_flow_api.g_varchar2_table(88) := '656C61746976653B0A202020666F6E742D73697A653A20313470783B0A2020206C696E652D6865696768743A20323070783B0A2020206D617267696E2D626F74746F6D3A203470783B0A2020202F2A20457874726120536D616C6C2053637265656E7320';
wwv_flow_api.g_varchar2_table(89) := '2A2F0A207D0A202E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6974656D3A6C6173742D6368696C64207B0A2020206D617267696E2D626F74746F6D3A20303B0A207D0A202E752D52544C202E666F732D416C657274';
wwv_flow_api.g_varchar2_table(90) := '2D2D70616765202E612D4E6F74696669636174696F6E2D6974656D207B0A20202070616464696E672D6C6566743A20303B0A20202070616464696E672D72696768743A20323070783B0A207D0A202E666F732D416C6572742D2D70616765202E612D4E6F';
wwv_flow_api.g_varchar2_table(91) := '74696669636174696F6E2D6974656D3A6265666F7265207B0A202020636F6E74656E743A2027273B0A202020706F736974696F6E3A206162736F6C7574653B0A2020206D617267696E3A203870783B0A202020746F703A20303B0A2020206C6566743A20';
wwv_flow_api.g_varchar2_table(92) := '303B0A20202077696474683A203470783B0A2020206865696768743A203470783B0A202020626F726465722D7261646975733A20313030253B0A2020206261636B67726F756E642D636F6C6F723A207267626128302C20302C20302C20302E35293B0A20';
wwv_flow_api.g_varchar2_table(93) := '7D0A202F2A2E752D52544C202E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6974656D3A6265666F7265207B2072696768743A20303B206C6566743A206175746F3B207D2A2F0A202E666F732D416C6572742D2D7061';
wwv_flow_api.g_varchar2_table(94) := '6765202E612D4E6F74696669636174696F6E2D6974656D202E612D427574746F6E2D2D6E6F74696669636174696F6E207B0A20202070616464696E673A203270783B0A2020206F7061636974793A20302E37353B0A202020766572746963616C2D616C69';
wwv_flow_api.g_varchar2_table(95) := '676E3A20746F703B0A207D0A202E666F732D416C6572742D2D70616765202E68746D6C64624F7261457272207B0A2020206D617267696E2D746F703A20302E3872656D3B0A202020646973706C61793A20626C6F636B3B0A202020666F6E742D73697A65';
wwv_flow_api.g_varchar2_table(96) := '3A20312E3172656D3B0A2020206C696E652D6865696768743A20312E3672656D3B0A202020666F6E742D66616D696C793A20274D656E6C6F272C2027436F6E736F6C6173272C206D6F6E6F73706163652C2073657269663B0A20202077686974652D7370';
wwv_flow_api.g_varchar2_table(97) := '6163653A207072652D6C696E653B0A207D0A202F2A2041636365737369626C652048656164696E67203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D';
wwv_flow_api.g_varchar2_table(98) := '3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F0A202E666F732D416C6572742D2D61636365737369626C6548656164696E67202E666F732D416C6572742D7469746C65207B0A202020626F726465723A20303B0A202020636C69703A207265637428302030';
wwv_flow_api.g_varchar2_table(99) := '20302030293B0A2020206865696768743A203170783B0A2020206D617267696E3A202D3170783B0A2020206F766572666C6F773A2068696464656E3B0A20202070616464696E673A20303B0A202020706F736974696F6E3A206162736F6C7574653B0A20';
wwv_flow_api.g_varchar2_table(100) := '202077696474683A203170783B0A207D0A202F2A2048696464656E2048656164696E6720284E6F742041636365737369626C6529203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D';
wwv_flow_api.g_varchar2_table(101) := '3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F0A202E666F732D416C6572742D2D72656D6F766548656164696E67202E666F732D416C6572742D7469746C65207B0A202020646973706C61793A206E6F6E653B0A207D0A2040';
wwv_flow_api.g_varchar2_table(102) := '6D6564696120286D61782D77696474683A20343830707829207B0A2020202E666F732D416C6572742D2D70616765207B0A20202020202F2A6C6566743A20312E3672656D3B2A2F0A20202020206D696E2D77696474683A20303B0A20202020206D61782D';
wwv_flow_api.g_varchar2_table(103) := '77696474683A206E6F6E653B0A2020207D0A2020202E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6974656D207B0A2020202020666F6E742D73697A653A20313270783B0A2020207D0A207D0A20406D656469612028';
wwv_flow_api.g_varchar2_table(104) := '6D61782D77696474683A20373638707829207B0A2020202E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D7469746C65207B0A2020202020666F6E742D73697A653A20312E3872656D3B0A2020207D0A207D0A202F2A';
wwv_flow_api.g_varchar2_table(105) := '202D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D202A2F0A202F2A2049636F6E2E6373';
wwv_flow_api.g_varchar2_table(106) := '73202A2F0A202E666F732D416C657274202E742D49636F6E2E69636F6E2D636C6F73653A6265666F7265207B0A202020666F6E742D66616D696C793A2022617065782D352D69636F6E2D666F6E74223B0A202020646973706C61793A20696E6C696E652D';
wwv_flow_api.g_varchar2_table(107) := '626C6F636B3B0A202020766572746963616C2D616C69676E3A20746F703B0A207D0A202E666F732D416C657274202E742D49636F6E2E69636F6E2D636C6F73653A6265666F7265207B0A2020206C696E652D6865696768743A20313670783B0A20202066';
wwv_flow_api.g_varchar2_table(108) := '6F6E742D73697A653A20313670783B0A202020636F6E74656E743A20225C65306132223B0A207D0A202F2A202D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D';
wwv_flow_api.g_varchar2_table(109) := '2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D202A2F0A202E666F7374722D746F702D63656E746572207B0A202020746F703A20312E3672656D3B0A20202072696768743A20303B0A20202077696474683A20313030253B0A207D';
wwv_flow_api.g_varchar2_table(110) := '0A202E666F7374722D626F74746F6D2D63656E746572207B0A202020626F74746F6D3A20312E3672656D3B0A20202072696768743A20303B0A20202077696474683A20313030253B0A207D0A202E666F7374722D746F702D7269676874207B0A20202074';
wwv_flow_api.g_varchar2_table(111) := '6F703A20312E3672656D3B0A20202072696768743A20312E3672656D3B0A207D0A202E666F7374722D746F702D6C656674207B0A202020746F703A20312E3672656D3B0A2020206C6566743A20312E3672656D3B0A207D0A202E666F7374722D626F7474';
wwv_flow_api.g_varchar2_table(112) := '6F6D2D7269676874207B0A20202072696768743A20312E3672656D3B0A202020626F74746F6D3A20312E3672656D3B0A207D0A202E666F7374722D626F74746F6D2D6C656674207B0A202020626F74746F6D3A20312E3672656D3B0A2020206C6566743A';
wwv_flow_api.g_varchar2_table(113) := '20312E3672656D3B0A207D0A202E666F7374722D636F6E7461696E6572207B0A202020706F736974696F6E3A2066697865643B0A2020207A2D696E6465783A203939393939393B0A202020706F696E7465722D6576656E74733A206E6F6E653B0A202020';
wwv_flow_api.g_varchar2_table(114) := '2F2A6F76657272696465732A2F0A207D0A202E666F7374722D636F6E7461696E6572203E20646976207B0A202020706F696E7465722D6576656E74733A206175746F3B0A207D0A202E666F7374722D636F6E7461696E65722E666F7374722D746F702D63';
wwv_flow_api.g_varchar2_table(115) := '656E746572203E206469762C0A202E666F7374722D636F6E7461696E65722E666F7374722D626F74746F6D2D63656E746572203E20646976207B0A2020202F2A77696474683A2033303070783B2A2F0A2020206D617267696E2D6C6566743A206175746F';
wwv_flow_api.g_varchar2_table(116) := '3B0A2020206D617267696E2D72696768743A206175746F3B0A207D0A202E666F7374722D70726F6772657373207B0A202020706F736974696F6E3A206162736F6C7574653B0A202020626F74746F6D3A20303B0A2020206865696768743A203470783B0A';
wwv_flow_api.g_varchar2_table(117) := '2020206261636B67726F756E642D636F6C6F723A20626C61636B3B0A2020206F7061636974793A20302E343B0A207D0A2068746D6C3A6E6F74282E752D52544C29202E666F7374722D70726F6772657373207B0A2020206C6566743A20303B0A20202062';
wwv_flow_api.g_varchar2_table(118) := '6F726465722D626F74746F6D2D6C6566742D7261646975733A20302E3472656D3B0A207D0A2068746D6C2E752D52544C202E666F7374722D70726F6772657373207B0A20202072696768743A20303B0A202020626F726465722D626F74746F6D2D726967';
wwv_flow_api.g_varchar2_table(119) := '68742D7261646975733A20302E3472656D3B0A207D0A20406D6564696120286D61782D77696474683A20343830707829207B0A2020202E666F7374722D636F6E7461696E6572207B0A20202020206C6566743A20312E3672656D3B0A2020202020726967';
wwv_flow_api.g_varchar2_table(120) := '68743A20312E3672656D3B0A2020207D0A207D0A200A200A20';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(729779056742330290)
,p_plugin_id=>wwv_flow_api.id(441585844511348477)
,p_file_name=>'css/fostr.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '7B2276657273696F6E223A332C22736F7572636573223A5B22666F7374722E637373225D2C226E616D6573223A5B5D2C226D617070696E6773223A22414155432C6F432C434144412C71432C434145452C612C434143412C79422C43414B462C73422C43';
wwv_flow_api.g_varchar2_table(2) := '4143452C69422C43413043412C71422C434143412C612C43417745412C6F422C434143412C69422C43416D44412C2B422C434143412C30432C4341744B462C75422C434143452C552C43414B462C32432C434143452C612C434145462C79442C43414345';
wwv_flow_api.g_varchar2_table(3) := '2C71432C43414B462C32432C434143452C75432C434145462C79442C434143452C6F432C43414B462C77432C434143452C6F432C434145462C73442C434143452C6F432C43414B462C30432C434143452C73432C434145462C77442C434143452C6F432C';
wwv_flow_api.g_varchar2_table(4) := '43416B42462C6D432C434143452C6B442C434143412C36432C434145462C6D442C434143452C34422C434143412C552C43413443462C30442C434164412C77442C43413542412C32442C434163412C32442C434162452C612C434145462C79442C434143';
wwv_flow_api.g_varchar2_table(5) := '452C6F422C434145462C6D432C434143452C77422C434143412C612C434145462C6D442C434143452C34422C434143412C612C43414B462C79442C434143452C6F422C434145462C67432C434143452C2B432C434143412C30432C434145462C67442C43';
wwv_flow_api.g_varchar2_table(6) := '4143452C34422C434143412C552C43414B462C73442C434143452C6F422C434145462C6B432C434143452C69442C434143412C34432C434145462C6B442C434143452C34422C434143412C552C43414B462C77442C434143452C6F422C43414F462C7343';
wwv_flow_api.g_varchar2_table(7) := '2C434143452C592C434143412C6B422C434145462C73432C434143452C632C434143412C612C434143412C592C434143412C6B422C434145462C79432C434143452C592C434143412C512C434143412C592C434143412C71422C434143412C73422C4341';
wwv_flow_api.g_varchar2_table(8) := '45462C79432C434143452C612C434143412C67422C434143412C6B422C434143412C6F422C434143412C592C434143412C6B422C434145462C67442C434143452C652C434143412C6D422C434155462C34432C434152412C2B432C434143452C592C4341';
wwv_flow_api.g_varchar2_table(9) := '45462C75432C434143452C632C434143412C6B422C434143412C652C43414B462C38432C434143452C632C434143412C552C434143412C69422C434143412C572C434143412C612C43414F462C77442C434143452C73422C434145462C30432C43414345';
wwv_flow_api.g_varchar2_table(10) := '2C592C434145462C612C434143452C512C434145462C77422C434143452C652C434147462C67422C434143452C75422C434143412C652C434143412C652C434145412C592C434143412C632C434143412C79452C43414D462C6D432C434143452C652C43';
wwv_flow_api.g_varchar2_table(11) := '4145462C67432C434143452C6D422C434143412C69422C434145462C75432C434143452C67422C434143412C6F422C434145462C77432C434143452C632C434143412C552C434143412C572C434143412C612C434145462C67432C434143452C6B422C43';
wwv_flow_api.g_varchar2_table(12) := '4143412C652C434143412C67422C434143412C652C434145462C6D432C434143452C572C434145462C73432C434143452C69422C434143412C552C434143412C512C434143412C572C434143412C572C434143412C2B422C434143412C6F422C43414341';
wwv_flow_api.g_varchar2_table(13) := '2C6F442C434143412C6B422C434145412C2B422C434143412C34442C434145462C36432C434143452C552C434143412C532C434145462C34432C434143452C36422C434143412C71422C434145462C36432C434143452C34422C434143412C6F422C4341';
wwv_flow_api.g_varchar2_table(14) := '47462C30422C434143452C6D422C434145462C69432C434143452C612C434145462C6D442C434143452C67422C434145462C79442C434143452C67422C434143412C67422C434143412C652C434143412C512C434145462C77442C434143452C67422C43';
wwv_flow_api.g_varchar2_table(15) := '4145462C71432C434143452C652C434143412C612C434145462C32432C434143452C79422C434145462C6F432C434143452C532C434143412C552C434145462C30432C434143452C67432C434145462C30432C434143452C67432C434145462C69432C43';
wwv_flow_api.g_varchar2_table(16) := '4143452C612C434143412C652C434143412C67422C434143412C652C434143412C69422C434145462C67432C434143452C69422C43414D462C75432C43414A412C77432C434143452C632C434143412C67422C43414D462C71432C434143452C632C4341';
wwv_flow_api.g_varchar2_table(17) := '43412C532C434143412C652C434145462C71432C434143452C69422C434143412C69422C434143412C632C434143412C67422C434143412C69422C434147462C67442C434143452C652C434145462C34432C434143452C632C434143412C6B422C434145';
wwv_flow_api.g_varchar2_table(18) := '462C34432C434143452C552C434143412C69422C434143412C552C434143412C4B2C434143412C4D2C434143412C532C434143412C552C434143412C6B422C434143412C2B422C434147462C36442C434143452C572C434143412C572C434143412C6B42';
wwv_flow_api.g_varchar2_table(19) := '2C434145462C38422C434143452C67422C434143412C612C434143412C67422C434143412C6B422C434143412C38432C434143412C6F422C434147462C38432C434143452C512C434143412C6B422C434143412C552C434143412C572C434143412C652C';
wwv_flow_api.g_varchar2_table(20) := '434143412C532C434143412C69422C434143412C532C434147462C30432C434143452C592C434145462C79424143452C67422C434145452C572C434143412C632C434145462C71432C434143452C674241474A2C412C79424143452C75432C434143452C';
wwv_flow_api.g_varchar2_table(21) := '6B42414B4A2C6F432C434143452C38422C434143412C6F422C434143412C6B422C434147412C67422C434143412C632C434143412C652C434147462C69422C434143452C552C434143412C4F2C434143412C552C434145462C6F422C434143452C612C43';
wwv_flow_api.g_varchar2_table(22) := '4143412C4F2C434143412C552C434145462C67422C434143452C552C434143412C592C434145462C652C434143452C552C434143412C572C434145462C6D422C434143452C592C434143412C612C434145462C6B422C434143452C612C434143412C572C';
wwv_flow_api.g_varchar2_table(23) := '434145462C67422C434143452C632C434143412C632C434143412C6D422C434147462C6F422C434143452C6D422C434147462C77432C434144412C71432C434147452C67422C434143412C69422C434145462C652C434143452C69422C434143412C512C';
wwv_flow_api.g_varchar2_table(24) := '434143412C552C434143412C71422C434143412C552C434145462C534141532C75422C434143502C4D2C434143412C2B422C434145462C30422C434143452C4F2C434143412C67432C434145462C79424143452C67422C434143452C572C434143412C63';
wwv_flow_api.g_varchar2_table(25) := '222C2266696C65223A22666F7374722E637373222C22736F7572636573436F6E74656E74223A5B222F2A5C6E5C6E5C744E6F7465735C6E5C745C742A206162736F6C757465206C65667420616E642072696768742076616C7565732073686F756C64206E';
wwv_flow_api.g_varchar2_table(26) := '6F7720626520706C61636573206F6E2074686520636F6E7461696E657220656C656D656E742C206E6F742074686520696E646976696475616C206E6F74696669636174696F6E735C6E5C6E2A2F5C6E2F2A2A5C6E202A204669786573206C696E6B207374';
wwv_flow_api.g_varchar2_table(27) := '796C696E6720696E206572726F72735C6E202A2F5C6E202E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E6720612C5C6E202E666F732D416C6572742D2D706167652E666F732D416C6572742D2D64616E6765722061';
wwv_flow_api.g_varchar2_table(28) := '207B5C6E202020636F6C6F723A20696E68657269743B5C6E202020746578742D6465636F726174696F6E3A20756E6465726C696E653B5C6E207D5C6E202F2A2A5C6E20202A20436F6C6F72697A6564204261636B67726F756E645C6E20202A2F5C6E202E';
wwv_flow_api.g_varchar2_table(29) := '666F732D416C6572742D2D686F72697A6F6E74616C207B5C6E202020626F726465722D7261646975733A203270783B5C6E207D5C6E202E666F732D416C6572742D69636F6E202E742D49636F6E207B5C6E202020636F6C6F723A20234646463B5C6E207D';
wwv_flow_api.g_varchar2_table(30) := '5C6E202F2A2A5C6E2020202A204D6F6469666965723A205761726E696E675C6E2020202A2F5C6E202E666F732D416C6572742D2D7761726E696E67202E666F732D416C6572742D69636F6E202E742D49636F6E207B5C6E202020636F6C6F723A20236662';
wwv_flow_api.g_varchar2_table(31) := '636634613B20205C6E207D5C6E202E666F732D416C6572742D2D7761726E696E672E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D69636F6E207B5C6E2020206261636B67726F756E642D636F6C6F723A2072676261';
wwv_flow_api.g_varchar2_table(32) := '283235312C203230372C2037342C20302E3135293B5C6E207D5C6E202F2A2A5C6E2020202A204D6F6469666965723A20537563636573735C6E2020202A2F5C6E202E666F732D416C6572742D2D73756363657373202E666F732D416C6572742D69636F6E';
wwv_flow_api.g_varchar2_table(33) := '202E742D49636F6E207B5C6E202020636F6C6F723A20766172282D2D612D70616C657474652D737563636573732C2023334241413243293B5C6E207D5C6E202E666F732D416C6572742D2D737563636573732E666F732D416C6572742D2D686F72697A6F';
wwv_flow_api.g_varchar2_table(34) := '6E74616C202E666F732D416C6572742D69636F6E207B5C6E2020206261636B67726F756E642D636F6C6F723A20726762612835392C203137302C2034342C20302E3135293B5C6E207D5C6E202F2A2A5C6E2020202A204D6F6469666965723A20496E666F';
wwv_flow_api.g_varchar2_table(35) := '726D6174696F6E5C6E2020202A2F5C6E202E666F732D416C6572742D2D696E666F202E666F732D416C6572742D69636F6E202E742D49636F6E207B5C6E202020636F6C6F723A20766172282D2D612D70616C657474652D696E666F2C2023303037366466';
wwv_flow_api.g_varchar2_table(36) := '293B5C6E207D5C6E202E666F732D416C6572742D2D696E666F2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D69636F6E207B5C6E2020206261636B67726F756E642D636F6C6F723A207267626128302C203131382C';
wwv_flow_api.g_varchar2_table(37) := '203232332C20302E3135293B5C6E207D5C6E202F2A2A5C6E2020202A204D6F6469666965723A2044616E6765725C6E2020202A2F5C6E202E666F732D416C6572742D2D64616E676572202E666F732D416C6572742D69636F6E202E742D49636F6E207B5C';
wwv_flow_api.g_varchar2_table(38) := '6E202020636F6C6F723A20766172282D2D612D70616C657474652D64616E6765722C2023663434333336293B5C6E207D5C6E202E666F732D416C6572742D2D64616E6765722E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C65';
wwv_flow_api.g_varchar2_table(39) := '72742D69636F6E207B5C6E2020206261636B67726F756E642D636F6C6F723A2072676261283234342C2036372C2035342C20302E3135293B5C6E207D5C6E202E666F732D416C6572742D2D686F72697A6F6E74616C207B5C6E2020206261636B67726F75';
wwv_flow_api.g_varchar2_table(40) := '6E642D636F6C6F723A20236666666666663B5C6E202020636F6C6F723A20233236323632363B5C6E207D5C6E202F2A5C6E202E666F732D416C6572742D2D64616E6765727B5C6E2020204062673A206C69676874656E2840675F44616E6765722D42472C';
wwv_flow_api.g_varchar2_table(41) := '20343025293B5C6E2020206261636B67726F756E642D636F6C6F723A204062673B5C6E202020636F6C6F723A206661646528636F6E7472617374284062672C2064657361747572617465286461726B656E284062672C202031303025292C203130302529';
wwv_flow_api.g_varchar2_table(42) := '2C2064657361747572617465286C69676874656E284062672C202031303025292C2035302529292C2031303025293B5C6E207D5C6E202E666F732D416C6572742D2D696E666F207B5C6E2020204062673A206C69676874656E2840675F496E666F2D4247';
wwv_flow_api.g_varchar2_table(43) := '2C20353525293B5C6E2020206261636B67726F756E642D636F6C6F723A204062673B5C6E202020636F6C6F723A206661646528636F6E7472617374284062672C2064657361747572617465286461726B656E284062672C202031303025292C2031303025';
wwv_flow_api.g_varchar2_table(44) := '292C2064657361747572617465286C69676874656E284062672C202031303025292C2035302529292C2031303025293B5C6E207D5C6E202A2F5C6E202E666F732D416C6572742D2D706167652E666F732D416C6572742D2D73756363657373207B5C6E20';
wwv_flow_api.g_varchar2_table(45) := '20206261636B67726F756E642D636F6C6F723A20766172282D2D612D70616C657474652D737563636573732C2023334241413243293B3B5C6E202020636F6C6F723A20766172282D2D612D70616C657474652D737563636573732D636F6E74726173742C';
wwv_flow_api.g_varchar2_table(46) := '2023464646293B5C6E207D5C6E202E666F732D416C6572742D2D706167652E666F732D416C6572742D2D73756363657373202E666F732D416C6572742D69636F6E207B5C6E2020206261636B67726F756E642D636F6C6F723A207472616E73706172656E';
wwv_flow_api.g_varchar2_table(47) := '743B5C6E202020636F6C6F723A20234646463B5C6E207D5C6E202E666F732D416C6572742D2D706167652E666F732D416C6572742D2D73756363657373202E666F732D416C6572742D69636F6E202E742D49636F6E207B5C6E202020636F6C6F723A2069';
wwv_flow_api.g_varchar2_table(48) := '6E68657269743B5C6E207D5C6E202E666F732D416C6572742D2D706167652E666F732D416C6572742D2D73756363657373202E742D427574746F6E2D2D636C6F7365416C657274207B5C6E202020636F6C6F723A20234646462021696D706F7274616E74';
wwv_flow_api.g_varchar2_table(49) := '3B5C6E207D5C6E202E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E67207B5C6E2020206261636B67726F756E642D636F6C6F723A20236662636634613B5C6E202020636F6C6F723A2020233434333430323B5C6E20';
wwv_flow_api.g_varchar2_table(50) := '7D5C6E202E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E67202E666F732D416C6572742D69636F6E207B5C6E2020206261636B67726F756E642D636F6C6F723A207472616E73706172656E743B5C6E202020636F6C';
wwv_flow_api.g_varchar2_table(51) := '6F723A20233434333430323B5C6E207D5C6E202E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E67202E666F732D416C6572742D69636F6E202E742D49636F6E207B5C6E202020636F6C6F723A20696E68657269743B';
wwv_flow_api.g_varchar2_table(52) := '5C6E207D5C6E202E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E67202E742D427574746F6E2D2D636C6F7365416C657274207B5C6E202020636F6C6F723A20234646462021696D706F7274616E743B5C6E207D5C6E';
wwv_flow_api.g_varchar2_table(53) := '202E666F732D416C6572742D2D706167652E666F732D416C6572742D2D696E666F207B5C6E2020206261636B67726F756E642D636F6C6F723A20766172282D2D612D70616C657474652D696E666F2C2023303037366466293B5C6E202020636F6C6F723A';
wwv_flow_api.g_varchar2_table(54) := '20766172282D2D612D70616C657474652D696E666F2D636F6E74726173742C2023464646293B5C6E207D5C6E202E666F732D416C6572742D2D706167652E666F732D416C6572742D2D696E666F202E666F732D416C6572742D69636F6E207B5C6E202020';
wwv_flow_api.g_varchar2_table(55) := '6261636B67726F756E642D636F6C6F723A207472616E73706172656E743B5C6E202020636F6C6F723A20234646463B5C6E207D5C6E202E666F732D416C6572742D2D706167652E666F732D416C6572742D2D696E666F202E666F732D416C6572742D6963';
wwv_flow_api.g_varchar2_table(56) := '6F6E202E742D49636F6E207B5C6E202020636F6C6F723A20696E68657269743B5C6E207D5C6E202E666F732D416C6572742D2D706167652E666F732D416C6572742D2D696E666F202E742D427574746F6E2D2D636C6F7365416C657274207B5C6E202020';
wwv_flow_api.g_varchar2_table(57) := '636F6C6F723A20234646462021696D706F7274616E743B5C6E207D5C6E202E666F732D416C6572742D2D706167652E666F732D416C6572742D2D64616E676572207B5C6E2020206261636B67726F756E642D636F6C6F723A20766172282D2D612D70616C';
wwv_flow_api.g_varchar2_table(58) := '657474652D64616E6765722C2023663434333336293B5C6E202020636F6C6F723A20766172282D2D612D70616C657474652D64616E6765722D636F6E74726173742C2023464646293B5C6E207D5C6E202E666F732D416C6572742D2D706167652E666F73';
wwv_flow_api.g_varchar2_table(59) := '2D416C6572742D2D64616E676572202E666F732D416C6572742D69636F6E207B5C6E2020206261636B67726F756E642D636F6C6F723A207472616E73706172656E743B5C6E202020636F6C6F723A20234646463B5C6E207D5C6E202E666F732D416C6572';
wwv_flow_api.g_varchar2_table(60) := '742D2D706167652E666F732D416C6572742D2D64616E676572202E666F732D416C6572742D69636F6E202E742D49636F6E207B5C6E202020636F6C6F723A20696E68657269743B5C6E207D5C6E202E666F732D416C6572742D2D706167652E666F732D41';
wwv_flow_api.g_varchar2_table(61) := '6C6572742D2D64616E676572202E742D427574746F6E2D2D636C6F7365416C657274207B5C6E202020636F6C6F723A20234646462021696D706F7274616E743B5C6E207D5C6E202F2A20486F72697A6F6E74616C20416C657274203D3D3D3D3D3D3D3D3D';
wwv_flow_api.g_varchar2_table(62) := '3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F5C6E202E666F732D416C6572742D2D686F72697A6F6E74616C207B5C6E202020';
wwv_flow_api.g_varchar2_table(63) := '6D617267696E2D626F74746F6D3A20312E3672656D3B5C6E202020706F736974696F6E3A2072656C61746976653B5C6E207D5C6E202E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D77726170207B5C6E2020206469';
wwv_flow_api.g_varchar2_table(64) := '73706C61793A20666C65783B5C6E202020666C65782D646972656374696F6E3A20726F773B5C6E207D5C6E202E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D69636F6E207B5C6E20202070616464696E673A203020';
wwv_flow_api.g_varchar2_table(65) := '313670783B5C6E202020666C65782D736872696E6B3A20303B5C6E202020646973706C61793A20666C65783B5C6E202020616C69676E2D6974656D733A2063656E7465723B5C6E207D5C6E202E666F732D416C6572742D2D686F72697A6F6E74616C202E';
wwv_flow_api.g_varchar2_table(66) := '666F732D416C6572742D636F6E74656E74207B5C6E20202070616464696E673A20313670783B5C6E202020666C65783A203120303B5C6E202020646973706C61793A20666C65783B5C6E202020666C65782D646972656374696F6E3A20636F6C756D6E3B';
wwv_flow_api.g_varchar2_table(67) := '5C6E2020206A7573746966792D636F6E74656E743A2063656E7465723B5C6E207D5C6E202E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D627574746F6E73207B5C6E202020666C65782D736872696E6B3A20303B5C';
wwv_flow_api.g_varchar2_table(68) := '6E202020746578742D616C69676E3A2072696768743B5C6E20202077686974652D73706163653A206E6F777261703B5C6E20202070616464696E672D72696768743A20312E3672656D3B5C6E202020646973706C61793A20666C65783B5C6E202020616C';
wwv_flow_api.g_varchar2_table(69) := '69676E2D6974656D733A2063656E7465723B5C6E207D5C6E202E752D52544C202E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D627574746F6E73207B5C6E20202070616464696E672D72696768743A20303B5C6E20';
wwv_flow_api.g_varchar2_table(70) := '202070616464696E672D6C6566743A20312E3672656D3B5C6E207D5C6E202E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D627574746F6E733A656D707479207B5C6E202020646973706C61793A206E6F6E653B5C6E';
wwv_flow_api.g_varchar2_table(71) := '207D5C6E202E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D7469746C65207B5C6E202020666F6E742D73697A653A203272656D3B5C6E2020206C696E652D6865696768743A20322E3472656D3B5C6E2020206D6172';
wwv_flow_api.g_varchar2_table(72) := '67696E2D626F74746F6D3A20303B5C6E207D5C6E202E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D626F64793A656D707479207B5C6E202020646973706C61793A206E6F6E653B5C6E207D5C6E202E666F732D416C';
wwv_flow_api.g_varchar2_table(73) := '6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D69636F6E202E742D49636F6E207B5C6E202020666F6E742D73697A653A20333270783B5C6E20202077696474683A20333270783B5C6E202020746578742D616C69676E3A2063656E74';
wwv_flow_api.g_varchar2_table(74) := '65723B5C6E2020206865696768743A20333270783B5C6E2020206C696E652D6865696768743A20313B5C6E207D5C6E202F2A203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D';
wwv_flow_api.g_varchar2_table(75) := '3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D20436F6D6D6F6E2050726F70657274696573203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D';
wwv_flow_api.g_varchar2_table(76) := '3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F5C6E202E666F732D416C6572742D2D686F72697A6F6E74616C207B5C6E202020626F726465723A2031707820736F6C6964207267626128302C20302C20302C20302E31293B5C6E202020626F782D73';
wwv_flow_api.g_varchar2_table(77) := '6861646F773A20302032707820347078202D327078207267626128302C20302C20302C20302E303735293B5C6E207D5C6E202E666F732D416C6572742D2D6E6F49636F6E2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572';
wwv_flow_api.g_varchar2_table(78) := '742D69636F6E207B5C6E202020646973706C61793A206E6F6E652021696D706F7274616E743B5C6E207D5C6E202E666F732D416C6572742D2D6E6F49636F6E202E666F732D416C6572742D69636F6E202E742D49636F6E207B5C6E202020646973706C61';
wwv_flow_api.g_varchar2_table(79) := '793A206E6F6E653B5C6E207D5C6E202E742D426F64792D616C657274207B5C6E2020206D617267696E3A20303B5C6E207D5C6E202E742D426F64792D616C657274202E666F732D416C657274207B5C6E2020206D617267696E2D626F74746F6D3A20303B';
wwv_flow_api.g_varchar2_table(80) := '5C6E207D5C6E202F2A2050616765204E6F74696669636174696F6E202853756363657373206F72204D65737361676529203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D';
wwv_flow_api.g_varchar2_table(81) := '3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F5C6E202E666F732D416C6572742D2D70616765207B5C6E2020207472616E736974696F6E3A20302E327320656173652D6F75743B5C6E2020206D61782D77696474683A2036343070783B';
wwv_flow_api.g_varchar2_table(82) := '5C6E2020206D696E2D77696474683A2033323070783B5C6E2020202F2A706F736974696F6E3A2066697865643B20746F703A20312E3672656D3B2072696768743A20312E3672656D3B2A2F5C6E2020207A2D696E6465783A20313030303B5C6E20202062';
wwv_flow_api.g_varchar2_table(83) := '6F726465722D77696474683A20303B5C6E202020626F782D736861646F773A20302030203020302E3172656D207267626128302C20302C20302C20302E312920696E7365742C20302033707820397078202D327078207267626128302C20302C20302C20';
wwv_flow_api.g_varchar2_table(84) := '302E31293B5C6E2020202F2A20466F72207665727920736D616C6C2073637265656E732C2066697420746865206D65737361676520746F2074686520746F70206F66207468652073637265656E202A2F5C6E2020202F2A2053657420426F726465722052';
wwv_flow_api.g_varchar2_table(85) := '616469757320746F2030206173206D657373616765206578697374732077697468696E20636F6E74656E74202A2F5C6E2020202F2A2050616765204C6576656C205761726E696E6720616E64204572726F7273203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D';
wwv_flow_api.g_varchar2_table(86) := '3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F5C6E2020202F2A205363726F6C6C62617273202A2F5C6E207D5C6E202E666F732D416C6572742D';
wwv_flow_api.g_varchar2_table(87) := '2D70616765202E666F732D416C6572742D627574746F6E73207B5C6E20202070616464696E672D72696768743A20303B5C6E207D5C6E202E666F732D416C6572742D2D70616765202E666F732D416C6572742D69636F6E207B5C6E20202070616464696E';
wwv_flow_api.g_varchar2_table(88) := '672D6C6566743A20312E3672656D3B5C6E20202070616464696E672D72696768743A203870783B5C6E207D5C6E202E752D52544C202E666F732D416C6572742D2D70616765202E666F732D416C6572742D69636F6E207B5C6E20202070616464696E672D';
wwv_flow_api.g_varchar2_table(89) := '6C6566743A203870783B5C6E20202070616464696E672D72696768743A20312E3672656D3B5C6E207D5C6E202E666F732D416C6572742D2D70616765202E666F732D416C6572742D69636F6E202E742D49636F6E207B5C6E202020666F6E742D73697A65';
wwv_flow_api.g_varchar2_table(90) := '3A20323470783B5C6E20202077696474683A20323470783B5C6E2020206865696768743A20323470783B5C6E2020206C696E652D6865696768743A20313B5C6E207D5C6E202E666F732D416C6572742D2D70616765202E666F732D416C6572742D626F64';
wwv_flow_api.g_varchar2_table(91) := '79207B5C6E20202070616464696E672D626F74746F6D3A203870783B5C6E20202070616464696E672D746F703A203870783B5C6E202020666F6E742D73697A653A20312E3672656D3B5C6E202020666F6E742D7765696768743A20626F6C643B5C6E207D';
wwv_flow_api.g_varchar2_table(92) := '5C6E202E666F732D416C6572742D2D70616765202E666F732D416C6572742D636F6E74656E74207B5C6E20202070616464696E673A203870783B5C6E207D5C6E202E666F732D416C6572742D2D70616765202E742D427574746F6E2D2D636C6F7365416C';
wwv_flow_api.g_varchar2_table(93) := '657274207B5C6E202020706F736974696F6E3A206162736F6C7574653B5C6E20202072696768743A202D3870783B5C6E202020746F703A202D3870783B5C6E20202070616464696E673A203470783B5C6E2020206D696E2D77696474683A20303B5C6E20';
wwv_flow_api.g_varchar2_table(94) := '20206261636B67726F756E642D636F6C6F723A20233030302021696D706F7274616E743B5C6E202020636F6C6F723A20234646462021696D706F7274616E743B5C6E202020626F782D736861646F773A203020302030203170782072676261283235352C';
wwv_flow_api.g_varchar2_table(95) := '203235352C203235352C20302E3235292021696D706F7274616E743B5C6E202020626F726465722D7261646975733A20323470783B5C6E2020207472616E736974696F6E3A202D7765626B69742D7472616E73666F726D20302E3132357320656173653B';
wwv_flow_api.g_varchar2_table(96) := '5C6E2020207472616E736974696F6E3A207472616E73666F726D20302E3132357320656173653B5C6E2020207472616E736974696F6E3A207472616E73666F726D20302E3132357320656173652C202D7765626B69742D7472616E73666F726D20302E31';
wwv_flow_api.g_varchar2_table(97) := '32357320656173653B5C6E207D5C6E202E752D52544C202E666F732D416C6572742D2D70616765202E742D427574746F6E2D2D636C6F7365416C657274207B5C6E20202072696768743A206175746F3B5C6E2020206C6566743A202D3870783B5C6E207D';
wwv_flow_api.g_varchar2_table(98) := '5C6E202E666F732D416C6572742D2D70616765202E742D427574746F6E2D2D636C6F7365416C6572743A686F766572207B5C6E2020202D7765626B69742D7472616E73666F726D3A207363616C6528312E3135293B5C6E2020207472616E73666F726D3A';
wwv_flow_api.g_varchar2_table(99) := '207363616C6528312E3135293B5C6E207D5C6E202E666F732D416C6572742D2D70616765202E742D427574746F6E2D2D636C6F7365416C6572743A616374697665207B5C6E2020202D7765626B69742D7472616E73666F726D3A207363616C6528302E38';
wwv_flow_api.g_varchar2_table(100) := '35293B5C6E2020207472616E73666F726D3A207363616C6528302E3835293B5C6E207D5C6E202F2A2E752D52544C202E666F732D416C6572742D2D70616765207B2072696768743A206175746F3B206C6566743A20312E3672656D3B207D2A2F5C6E202E';
wwv_flow_api.g_varchar2_table(101) := '666F732D416C6572742D2D706167652E666F732D416C657274207B5C6E202020626F726465722D7261646975733A20302E3472656D3B5C6E207D5C6E202E666F732D416C6572742D2D70616765202E666F732D416C6572742D7469746C65207B5C6E2020';
wwv_flow_api.g_varchar2_table(102) := '2070616464696E673A2038707820303B5C6E207D5C6E202E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E67202E612D4E6F74696669636174696F6E207B5C6E2020206D617267696E2D72696768743A203870783B5C';
wwv_flow_api.g_varchar2_table(103) := '6E207D5C6E202E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E67202E612D4E6F74696669636174696F6E2D7469746C65207B5C6E202020666F6E742D73697A653A20312E3472656D3B5C6E2020206C696E652D6865';
wwv_flow_api.g_varchar2_table(104) := '696768743A203272656D3B5C6E202020666F6E742D7765696768743A203730303B5C6E2020206D617267696E3A20303B5C6E207D5C6E202E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E67202E612D4E6F74696669';
wwv_flow_api.g_varchar2_table(105) := '636174696F6E2D6C697374207B5C6E2020206D61782D6865696768743A2031323870783B5C6E207D5C6E202E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6C697374207B5C6E2020206D61782D6865696768743A2039';
wwv_flow_api.g_varchar2_table(106) := '3670783B5C6E2020206F766572666C6F773A206175746F3B5C6E207D5C6E202E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6C696E6B3A686F766572207B5C6E202020746578742D6465636F726174696F6E3A20756E';
wwv_flow_api.g_varchar2_table(107) := '6465726C696E653B5C6E207D5C6E202E666F732D416C6572742D2D70616765203A3A2D7765626B69742D7363726F6C6C626172207B5C6E20202077696474683A203870783B5C6E2020206865696768743A203870783B5C6E207D5C6E202E666F732D416C';
wwv_flow_api.g_varchar2_table(108) := '6572742D2D70616765203A3A2D7765626B69742D7363726F6C6C6261722D7468756D62207B5C6E2020206261636B67726F756E642D636F6C6F723A207267626128302C20302C20302C20302E3235293B5C6E207D5C6E202E666F732D416C6572742D2D70';
wwv_flow_api.g_varchar2_table(109) := '616765203A3A2D7765626B69742D7363726F6C6C6261722D747261636B207B5C6E2020206261636B67726F756E642D636F6C6F723A207267626128302C20302C20302C20302E3035293B5C6E207D5C6E202E666F732D416C6572742D2D70616765202E66';
wwv_flow_api.g_varchar2_table(110) := '6F732D416C6572742D7469746C65207B5C6E202020646973706C61793A20626C6F636B3B5C6E202020666F6E742D7765696768743A203730303B5C6E202020666F6E742D73697A653A20312E3872656D3B5C6E2020206D617267696E2D626F74746F6D3A';
wwv_flow_api.g_varchar2_table(111) := '20303B5C6E2020206D617267696E2D72696768743A20313670783B5C6E207D5C6E202E666F732D416C6572742D2D70616765202E666F732D416C6572742D626F6479207B5C6E2020206D617267696E2D72696768743A20313670783B5C6E207D5C6E202E';
wwv_flow_api.g_varchar2_table(112) := '752D52544C202E666F732D416C6572742D2D70616765202E666F732D416C6572742D7469746C65207B5C6E2020206D617267696E2D72696768743A20303B5C6E2020206D617267696E2D6C6566743A20313670783B5C6E207D5C6E202E752D52544C202E';
wwv_flow_api.g_varchar2_table(113) := '666F732D416C6572742D2D70616765202E666F732D416C6572742D626F6479207B5C6E2020206D617267696E2D72696768743A20303B5C6E2020206D617267696E2D6C6566743A20313670783B5C6E207D5C6E202E666F732D416C6572742D2D70616765';
wwv_flow_api.g_varchar2_table(114) := '202E612D4E6F74696669636174696F6E2D6C697374207B5C6E2020206D617267696E3A203470782030203020303B5C6E20202070616464696E673A20303B5C6E2020206C6973742D7374796C653A206E6F6E653B5C6E207D5C6E202E666F732D416C6572';
wwv_flow_api.g_varchar2_table(115) := '742D2D70616765202E612D4E6F74696669636174696F6E2D6974656D207B5C6E20202070616464696E672D6C6566743A20323070783B5C6E202020706F736974696F6E3A2072656C61746976653B5C6E202020666F6E742D73697A653A20313470783B5C';
wwv_flow_api.g_varchar2_table(116) := '6E2020206C696E652D6865696768743A20323070783B5C6E2020206D617267696E2D626F74746F6D3A203470783B5C6E2020202F2A20457874726120536D616C6C2053637265656E73202A2F5C6E207D5C6E202E666F732D416C6572742D2D7061676520';
wwv_flow_api.g_varchar2_table(117) := '2E612D4E6F74696669636174696F6E2D6974656D3A6C6173742D6368696C64207B5C6E2020206D617267696E2D626F74746F6D3A20303B5C6E207D5C6E202E752D52544C202E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F';
wwv_flow_api.g_varchar2_table(118) := '6E2D6974656D207B5C6E20202070616464696E672D6C6566743A20303B5C6E20202070616464696E672D72696768743A20323070783B5C6E207D5C6E202E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6974656D3A62';
wwv_flow_api.g_varchar2_table(119) := '65666F7265207B5C6E202020636F6E74656E743A2027273B5C6E202020706F736974696F6E3A206162736F6C7574653B5C6E2020206D617267696E3A203870783B5C6E202020746F703A20303B5C6E2020206C6566743A20303B5C6E2020207769647468';
wwv_flow_api.g_varchar2_table(120) := '3A203470783B5C6E2020206865696768743A203470783B5C6E202020626F726465722D7261646975733A20313030253B5C6E2020206261636B67726F756E642D636F6C6F723A207267626128302C20302C20302C20302E35293B5C6E207D5C6E202F2A2E';
wwv_flow_api.g_varchar2_table(121) := '752D52544C202E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6974656D3A6265666F7265207B2072696768743A20303B206C6566743A206175746F3B207D2A2F5C6E202E666F732D416C6572742D2D70616765202E61';
wwv_flow_api.g_varchar2_table(122) := '2D4E6F74696669636174696F6E2D6974656D202E612D427574746F6E2D2D6E6F74696669636174696F6E207B5C6E20202070616464696E673A203270783B5C6E2020206F7061636974793A20302E37353B5C6E202020766572746963616C2D616C69676E';
wwv_flow_api.g_varchar2_table(123) := '3A20746F703B5C6E207D5C6E202E666F732D416C6572742D2D70616765202E68746D6C64624F7261457272207B5C6E2020206D617267696E2D746F703A20302E3872656D3B5C6E202020646973706C61793A20626C6F636B3B5C6E202020666F6E742D73';
wwv_flow_api.g_varchar2_table(124) := '697A653A20312E3172656D3B5C6E2020206C696E652D6865696768743A20312E3672656D3B5C6E202020666F6E742D66616D696C793A20274D656E6C6F272C2027436F6E736F6C6173272C206D6F6E6F73706163652C2073657269663B5C6E2020207768';
wwv_flow_api.g_varchar2_table(125) := '6974652D73706163653A207072652D6C696E653B5C6E207D5C6E202F2A2041636365737369626C652048656164696E67203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D';
wwv_flow_api.g_varchar2_table(126) := '3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F5C6E202E666F732D416C6572742D2D61636365737369626C6548656164696E67202E666F732D416C6572742D7469746C65207B5C6E202020626F726465723A20303B5C6E202020636C69';
wwv_flow_api.g_varchar2_table(127) := '703A20726563742830203020302030293B5C6E2020206865696768743A203170783B5C6E2020206D617267696E3A202D3170783B5C6E2020206F766572666C6F773A2068696464656E3B5C6E20202070616464696E673A20303B5C6E202020706F736974';
wwv_flow_api.g_varchar2_table(128) := '696F6E3A206162736F6C7574653B5C6E20202077696474683A203170783B5C6E207D5C6E202F2A2048696464656E2048656164696E6720284E6F742041636365737369626C6529203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D';
wwv_flow_api.g_varchar2_table(129) := '3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F5C6E202E666F732D416C6572742D2D72656D6F766548656164696E67202E666F732D416C6572742D7469746C65207B5C6E2020';
wwv_flow_api.g_varchar2_table(130) := '20646973706C61793A206E6F6E653B5C6E207D5C6E20406D6564696120286D61782D77696474683A20343830707829207B5C6E2020202E666F732D416C6572742D2D70616765207B5C6E20202020202F2A6C6566743A20312E3672656D3B2A2F5C6E2020';
wwv_flow_api.g_varchar2_table(131) := '2020206D696E2D77696474683A20303B5C6E20202020206D61782D77696474683A206E6F6E653B5C6E2020207D5C6E2020202E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6974656D207B5C6E2020202020666F6E74';
wwv_flow_api.g_varchar2_table(132) := '2D73697A653A20313270783B5C6E2020207D5C6E207D5C6E20406D6564696120286D61782D77696474683A20373638707829207B5C6E2020202E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D7469746C65207B5C6E';
wwv_flow_api.g_varchar2_table(133) := '2020202020666F6E742D73697A653A20312E3872656D3B5C6E2020207D5C6E207D5C6E202F2A202D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D';
wwv_flow_api.g_varchar2_table(134) := '2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D202A2F5C6E202F2A2049636F6E2E637373202A2F5C6E202E666F732D416C657274202E742D49636F6E2E69636F6E2D636C6F73653A6265666F7265207B5C6E202020666F6E742D66616D696C79';
wwv_flow_api.g_varchar2_table(135) := '3A205C22617065782D352D69636F6E2D666F6E745C223B5C6E202020646973706C61793A20696E6C696E652D626C6F636B3B5C6E202020766572746963616C2D616C69676E3A20746F703B5C6E207D5C6E202E666F732D416C657274202E742D49636F6E';
wwv_flow_api.g_varchar2_table(136) := '2E69636F6E2D636C6F73653A6265666F7265207B5C6E2020206C696E652D6865696768743A20313670783B5C6E202020666F6E742D73697A653A20313670783B5C6E202020636F6E74656E743A205C225C5C653061325C223B5C6E207D5C6E202F2A202D';
wwv_flow_api.g_varchar2_table(137) := '2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D202A2F5C6E202E666F7374722D746F702D';
wwv_flow_api.g_varchar2_table(138) := '63656E746572207B5C6E202020746F703A20312E3672656D3B5C6E20202072696768743A20303B5C6E20202077696474683A20313030253B5C6E207D5C6E202E666F7374722D626F74746F6D2D63656E746572207B5C6E202020626F74746F6D3A20312E';
wwv_flow_api.g_varchar2_table(139) := '3672656D3B5C6E20202072696768743A20303B5C6E20202077696474683A20313030253B5C6E207D5C6E202E666F7374722D746F702D7269676874207B5C6E202020746F703A20312E3672656D3B5C6E20202072696768743A20312E3672656D3B5C6E20';
wwv_flow_api.g_varchar2_table(140) := '7D5C6E202E666F7374722D746F702D6C656674207B5C6E202020746F703A20312E3672656D3B5C6E2020206C6566743A20312E3672656D3B5C6E207D5C6E202E666F7374722D626F74746F6D2D7269676874207B5C6E20202072696768743A20312E3672';
wwv_flow_api.g_varchar2_table(141) := '656D3B5C6E202020626F74746F6D3A20312E3672656D3B5C6E207D5C6E202E666F7374722D626F74746F6D2D6C656674207B5C6E202020626F74746F6D3A20312E3672656D3B5C6E2020206C6566743A20312E3672656D3B5C6E207D5C6E202E666F7374';
wwv_flow_api.g_varchar2_table(142) := '722D636F6E7461696E6572207B5C6E202020706F736974696F6E3A2066697865643B5C6E2020207A2D696E6465783A203939393939393B5C6E202020706F696E7465722D6576656E74733A206E6F6E653B5C6E2020202F2A6F76657272696465732A2F5C';
wwv_flow_api.g_varchar2_table(143) := '6E207D5C6E202E666F7374722D636F6E7461696E6572203E20646976207B5C6E202020706F696E7465722D6576656E74733A206175746F3B5C6E207D5C6E202E666F7374722D636F6E7461696E65722E666F7374722D746F702D63656E746572203E2064';
wwv_flow_api.g_varchar2_table(144) := '69762C5C6E202E666F7374722D636F6E7461696E65722E666F7374722D626F74746F6D2D63656E746572203E20646976207B5C6E2020202F2A77696474683A2033303070783B2A2F5C6E2020206D617267696E2D6C6566743A206175746F3B5C6E202020';
wwv_flow_api.g_varchar2_table(145) := '6D617267696E2D72696768743A206175746F3B5C6E207D5C6E202E666F7374722D70726F6772657373207B5C6E202020706F736974696F6E3A206162736F6C7574653B5C6E202020626F74746F6D3A20303B5C6E2020206865696768743A203470783B5C';
wwv_flow_api.g_varchar2_table(146) := '6E2020206261636B67726F756E642D636F6C6F723A20626C61636B3B5C6E2020206F7061636974793A20302E343B5C6E207D5C6E2068746D6C3A6E6F74282E752D52544C29202E666F7374722D70726F6772657373207B5C6E2020206C6566743A20303B';
wwv_flow_api.g_varchar2_table(147) := '5C6E202020626F726465722D626F74746F6D2D6C6566742D7261646975733A20302E3472656D3B5C6E207D5C6E2068746D6C2E752D52544C202E666F7374722D70726F6772657373207B5C6E20202072696768743A20303B5C6E202020626F726465722D';
wwv_flow_api.g_varchar2_table(148) := '626F74746F6D2D72696768742D7261646975733A20302E3472656D3B5C6E207D5C6E20406D6564696120286D61782D77696474683A20343830707829207B5C6E2020202E666F7374722D636F6E7461696E6572207B5C6E20202020206C6566743A20312E';
wwv_flow_api.g_varchar2_table(149) := '3672656D3B5C6E202020202072696768743A20312E3672656D3B5C6E2020207D5C6E207D5C6E205C6E205C6E20225D7D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(729779513270330291)
,p_plugin_id=>wwv_flow_api.id(441585844511348477)
,p_file_name=>'css/fostr.css.map'
,p_mime_type=>'application/json'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D64616E67657220612C2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E6720617B636F6C6F723A696E68657269743B746578742D6465636F7261';
wwv_flow_api.g_varchar2_table(2) := '74696F6E3A756E6465726C696E657D2E666F732D416C6572742D2D686F72697A6F6E74616C7B626F726465722D7261646975733A3270783B6261636B67726F756E642D636F6C6F723A236666663B636F6C6F723A233236323632363B6D617267696E2D62';
wwv_flow_api.g_varchar2_table(3) := '6F74746F6D3A312E3672656D3B706F736974696F6E3A72656C61746976653B626F726465723A31707820736F6C6964207267626128302C302C302C2E31293B626F782D736861646F773A302032707820347078202D327078207267626128302C302C302C';
wwv_flow_api.g_varchar2_table(4) := '2E303735297D2E666F732D416C6572742D69636F6E202E742D49636F6E7B636F6C6F723A236666667D2E666F732D416C6572742D2D7761726E696E67202E666F732D416C6572742D69636F6E202E742D49636F6E7B636F6C6F723A236662636634617D2E';
wwv_flow_api.g_varchar2_table(5) := '666F732D416C6572742D2D7761726E696E672E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D69636F6E7B6261636B67726F756E642D636F6C6F723A72676261283235312C3230372C37342C2E3135297D2E666F732D';
wwv_flow_api.g_varchar2_table(6) := '416C6572742D2D73756363657373202E666F732D416C6572742D69636F6E202E742D49636F6E7B636F6C6F723A766172282D2D612D70616C657474652D737563636573732C2023334241413243297D2E666F732D416C6572742D2D737563636573732E66';
wwv_flow_api.g_varchar2_table(7) := '6F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D69636F6E7B6261636B67726F756E642D636F6C6F723A726762612835392C3137302C34342C2E3135297D2E666F732D416C6572742D2D696E666F202E666F732D416C6572';
wwv_flow_api.g_varchar2_table(8) := '742D69636F6E202E742D49636F6E7B636F6C6F723A766172282D2D612D70616C657474652D696E666F2C2023303037366466297D2E666F732D416C6572742D2D696E666F2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572';
wwv_flow_api.g_varchar2_table(9) := '742D69636F6E7B6261636B67726F756E642D636F6C6F723A7267626128302C3131382C3232332C2E3135297D2E666F732D416C6572742D2D64616E676572202E666F732D416C6572742D69636F6E202E742D49636F6E7B636F6C6F723A766172282D2D61';
wwv_flow_api.g_varchar2_table(10) := '2D70616C657474652D64616E6765722C2023663434333336297D2E666F732D416C6572742D2D64616E6765722E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D69636F6E7B6261636B67726F756E642D636F6C6F723A';
wwv_flow_api.g_varchar2_table(11) := '72676261283234342C36372C35342C2E3135297D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D737563636573737B6261636B67726F756E642D636F6C6F723A766172282D2D612D70616C657474652D737563636573732C202333';
wwv_flow_api.g_varchar2_table(12) := '4241413243293B636F6C6F723A766172282D2D612D70616C657474652D737563636573732D636F6E74726173742C2023464646297D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D73756363657373202E666F732D416C6572742D';
wwv_flow_api.g_varchar2_table(13) := '69636F6E7B6261636B67726F756E642D636F6C6F723A7472616E73706172656E743B636F6C6F723A236666667D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D64616E676572202E666F732D416C6572742D69636F6E202E742D49';
wwv_flow_api.g_varchar2_table(14) := '636F6E2C2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D696E666F202E666F732D416C6572742D69636F6E202E742D49636F6E2C2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D73756363657373202E666F';
wwv_flow_api.g_varchar2_table(15) := '732D416C6572742D69636F6E202E742D49636F6E2C2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E67202E666F732D416C6572742D69636F6E202E742D49636F6E7B636F6C6F723A696E68657269747D2E666F732D';
wwv_flow_api.g_varchar2_table(16) := '416C6572742D2D706167652E666F732D416C6572742D2D73756363657373202E742D427574746F6E2D2D636C6F7365416C6572747B636F6C6F723A2366666621696D706F7274616E747D2E666F732D416C6572742D2D706167652E666F732D416C657274';
wwv_flow_api.g_varchar2_table(17) := '2D2D7761726E696E677B6261636B67726F756E642D636F6C6F723A236662636634613B636F6C6F723A233434333430327D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E67202E666F732D416C6572742D69636F6E';
wwv_flow_api.g_varchar2_table(18) := '7B6261636B67726F756E642D636F6C6F723A7472616E73706172656E743B636F6C6F723A233434333430327D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E67202E742D427574746F6E2D2D636C6F7365416C6572';
wwv_flow_api.g_varchar2_table(19) := '747B636F6C6F723A2366666621696D706F7274616E747D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D696E666F7B6261636B67726F756E642D636F6C6F723A766172282D2D612D70616C657474652D696E666F2C202330303736';
wwv_flow_api.g_varchar2_table(20) := '6466293B636F6C6F723A766172282D2D612D70616C657474652D696E666F2D636F6E74726173742C2023464646297D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D696E666F202E666F732D416C6572742D69636F6E7B6261636B';
wwv_flow_api.g_varchar2_table(21) := '67726F756E642D636F6C6F723A7472616E73706172656E743B636F6C6F723A236666667D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D696E666F202E742D427574746F6E2D2D636C6F7365416C6572747B636F6C6F723A236666';
wwv_flow_api.g_varchar2_table(22) := '6621696D706F7274616E747D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D64616E6765727B6261636B67726F756E642D636F6C6F723A766172282D2D612D70616C657474652D64616E6765722C2023663434333336293B636F6C';
wwv_flow_api.g_varchar2_table(23) := '6F723A766172282D2D612D70616C657474652D64616E6765722D636F6E74726173742C2023464646297D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D64616E676572202E666F732D416C6572742D69636F6E7B6261636B67726F';
wwv_flow_api.g_varchar2_table(24) := '756E642D636F6C6F723A7472616E73706172656E743B636F6C6F723A236666667D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D64616E676572202E742D427574746F6E2D2D636C6F7365416C6572747B636F6C6F723A23666666';
wwv_flow_api.g_varchar2_table(25) := '21696D706F7274616E747D2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D777261707B646973706C61793A666C65783B666C65782D646972656374696F6E3A726F777D2E666F732D416C6572742D2D686F72697A6F';
wwv_flow_api.g_varchar2_table(26) := '6E74616C202E666F732D416C6572742D69636F6E7B70616464696E673A3020313670783B666C65782D736872696E6B3A303B646973706C61793A666C65783B616C69676E2D6974656D733A63656E7465727D2E666F732D416C6572742D2D686F72697A6F';
wwv_flow_api.g_varchar2_table(27) := '6E74616C202E666F732D416C6572742D636F6E74656E747B70616464696E673A313670783B666C65783A3120303B646973706C61793A666C65783B666C65782D646972656374696F6E3A636F6C756D6E3B6A7573746966792D636F6E74656E743A63656E';
wwv_flow_api.g_varchar2_table(28) := '7465727D2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D627574746F6E737B666C65782D736872696E6B3A303B746578742D616C69676E3A72696768743B77686974652D73706163653A6E6F777261703B70616464';
wwv_flow_api.g_varchar2_table(29) := '696E672D72696768743A312E3672656D3B646973706C61793A666C65783B616C69676E2D6974656D733A63656E7465727D2E752D52544C202E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D627574746F6E737B7061';
wwv_flow_api.g_varchar2_table(30) := '6464696E672D72696768743A303B70616464696E672D6C6566743A312E3672656D7D2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D626F64793A656D7074792C2E666F732D416C6572742D2D686F72697A6F6E7461';
wwv_flow_api.g_varchar2_table(31) := '6C202E666F732D416C6572742D627574746F6E733A656D7074797B646973706C61793A6E6F6E657D2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D7469746C657B666F6E742D73697A653A3272656D3B6C696E652D';
wwv_flow_api.g_varchar2_table(32) := '6865696768743A322E3472656D3B6D617267696E2D626F74746F6D3A307D2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D69636F6E202E742D49636F6E7B666F6E742D73697A653A333270783B77696474683A3332';
wwv_flow_api.g_varchar2_table(33) := '70783B746578742D616C69676E3A63656E7465723B6865696768743A333270783B6C696E652D6865696768743A317D2E666F732D416C6572742D2D6E6F49636F6E2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C6572742D69';
wwv_flow_api.g_varchar2_table(34) := '636F6E7B646973706C61793A6E6F6E6521696D706F7274616E747D2E666F732D416C6572742D2D6E6F49636F6E202E666F732D416C6572742D69636F6E202E742D49636F6E7B646973706C61793A6E6F6E657D2E742D426F64792D616C6572747B6D6172';
wwv_flow_api.g_varchar2_table(35) := '67696E3A307D2E742D426F64792D616C657274202E666F732D416C6572747B6D617267696E2D626F74746F6D3A307D2E666F732D416C6572742D2D706167657B7472616E736974696F6E3A2E327320656173652D6F75743B6D61782D77696474683A3634';
wwv_flow_api.g_varchar2_table(36) := '3070783B6D696E2D77696474683A33323070783B7A2D696E6465783A313030303B626F726465722D77696474683A303B626F782D736861646F773A3020302030202E3172656D207267626128302C302C302C2E312920696E7365742C3020337078203970';
wwv_flow_api.g_varchar2_table(37) := '78202D327078207267626128302C302C302C2E31297D2E666F732D416C6572742D2D70616765202E666F732D416C6572742D627574746F6E737B70616464696E672D72696768743A307D2E666F732D416C6572742D2D70616765202E666F732D416C6572';
wwv_flow_api.g_varchar2_table(38) := '742D69636F6E7B70616464696E672D6C6566743A312E3672656D3B70616464696E672D72696768743A3870787D2E752D52544C202E666F732D416C6572742D2D70616765202E666F732D416C6572742D69636F6E7B70616464696E672D6C6566743A3870';
wwv_flow_api.g_varchar2_table(39) := '783B70616464696E672D72696768743A312E3672656D7D2E666F732D416C6572742D2D70616765202E666F732D416C6572742D69636F6E202E742D49636F6E7B666F6E742D73697A653A323470783B77696474683A323470783B6865696768743A323470';
wwv_flow_api.g_varchar2_table(40) := '783B6C696E652D6865696768743A317D2E666F732D416C6572742D2D70616765202E666F732D416C6572742D626F64797B70616464696E672D626F74746F6D3A3870783B70616464696E672D746F703A3870783B666F6E742D73697A653A312E3672656D';
wwv_flow_api.g_varchar2_table(41) := '3B666F6E742D7765696768743A3730307D2E666F732D416C6572742D2D70616765202E666F732D416C6572742D636F6E74656E747B70616464696E673A3870787D2E666F732D416C6572742D2D70616765202E742D427574746F6E2D2D636C6F7365416C';
wwv_flow_api.g_varchar2_table(42) := '6572747B706F736974696F6E3A6162736F6C7574653B72696768743A2D3870783B746F703A2D3870783B70616464696E673A3470783B6D696E2D77696474683A303B6261636B67726F756E642D636F6C6F723A2330303021696D706F7274616E743B636F';
wwv_flow_api.g_varchar2_table(43) := '6C6F723A2366666621696D706F7274616E743B626F782D736861646F773A3020302030203170782072676261283235352C3235352C3235352C2E32352921696D706F7274616E743B626F726465722D7261646975733A323470783B7472616E736974696F';
wwv_flow_api.g_varchar2_table(44) := '6E3A7472616E73666F726D202E3132357320656173653B7472616E736974696F6E3A7472616E73666F726D202E3132357320656173652C2D7765626B69742D7472616E73666F726D202E3132357320656173657D2E752D52544C202E666F732D416C6572';
wwv_flow_api.g_varchar2_table(45) := '742D2D70616765202E742D427574746F6E2D2D636C6F7365416C6572747B72696768743A6175746F3B6C6566743A2D3870787D2E666F732D416C6572742D2D70616765202E742D427574746F6E2D2D636C6F7365416C6572743A686F7665727B2D776562';
wwv_flow_api.g_varchar2_table(46) := '6B69742D7472616E73666F726D3A7363616C6528312E3135293B7472616E73666F726D3A7363616C6528312E3135297D2E666F732D416C6572742D2D70616765202E742D427574746F6E2D2D636C6F7365416C6572743A6163746976657B2D7765626B69';
wwv_flow_api.g_varchar2_table(47) := '742D7472616E73666F726D3A7363616C65282E3835293B7472616E73666F726D3A7363616C65282E3835297D2E666F732D416C6572742D2D706167652E666F732D416C6572747B626F726465722D7261646975733A2E3472656D7D2E666F732D416C6572';
wwv_flow_api.g_varchar2_table(48) := '742D2D70616765202E666F732D416C6572742D7469746C657B70616464696E673A38707820307D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E67202E612D4E6F74696669636174696F6E7B6D617267696E2D7269';
wwv_flow_api.g_varchar2_table(49) := '6768743A3870787D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E67202E612D4E6F74696669636174696F6E2D7469746C657B666F6E742D73697A653A312E3472656D3B6C696E652D6865696768743A3272656D3B';
wwv_flow_api.g_varchar2_table(50) := '666F6E742D7765696768743A3730303B6D617267696E3A307D2E666F732D416C6572742D2D706167652E666F732D416C6572742D2D7761726E696E67202E612D4E6F74696669636174696F6E2D6C6973747B6D61782D6865696768743A31323870787D2E';
wwv_flow_api.g_varchar2_table(51) := '666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6C6973747B6D61782D6865696768743A393670783B6F766572666C6F773A6175746F7D2E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D';
wwv_flow_api.g_varchar2_table(52) := '6C696E6B3A686F7665727B746578742D6465636F726174696F6E3A756E6465726C696E657D2E666F732D416C6572742D2D70616765203A3A2D7765626B69742D7363726F6C6C6261727B77696474683A3870783B6865696768743A3870787D2E666F732D';
wwv_flow_api.g_varchar2_table(53) := '416C6572742D2D70616765203A3A2D7765626B69742D7363726F6C6C6261722D7468756D627B6261636B67726F756E642D636F6C6F723A7267626128302C302C302C2E3235297D2E666F732D416C6572742D2D70616765203A3A2D7765626B69742D7363';
wwv_flow_api.g_varchar2_table(54) := '726F6C6C6261722D747261636B7B6261636B67726F756E642D636F6C6F723A7267626128302C302C302C2E3035297D2E666F732D416C6572742D2D70616765202E666F732D416C6572742D7469746C657B646973706C61793A626C6F636B3B666F6E742D';
wwv_flow_api.g_varchar2_table(55) := '7765696768743A3730303B666F6E742D73697A653A312E3872656D3B6D617267696E2D626F74746F6D3A303B6D617267696E2D72696768743A313670787D2E666F732D416C6572742D2D70616765202E666F732D416C6572742D626F64797B6D61726769';
wwv_flow_api.g_varchar2_table(56) := '6E2D72696768743A313670787D2E752D52544C202E666F732D416C6572742D2D70616765202E666F732D416C6572742D626F64792C2E752D52544C202E666F732D416C6572742D2D70616765202E666F732D416C6572742D7469746C657B6D617267696E';
wwv_flow_api.g_varchar2_table(57) := '2D72696768743A303B6D617267696E2D6C6566743A313670787D2E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6C6973747B6D617267696E3A347078203020303B70616464696E673A303B6C6973742D7374796C653A';
wwv_flow_api.g_varchar2_table(58) := '6E6F6E657D2E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6974656D7B70616464696E672D6C6566743A323070783B706F736974696F6E3A72656C61746976653B666F6E742D73697A653A313470783B6C696E652D68';
wwv_flow_api.g_varchar2_table(59) := '65696768743A323070783B6D617267696E2D626F74746F6D3A3470787D2E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6974656D3A6C6173742D6368696C647B6D617267696E2D626F74746F6D3A307D2E752D52544C';
wwv_flow_api.g_varchar2_table(60) := '202E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6974656D7B70616464696E672D6C6566743A303B70616464696E672D72696768743A323070787D2E666F732D416C6572742D2D70616765202E612D4E6F7469666963';
wwv_flow_api.g_varchar2_table(61) := '6174696F6E2D6974656D3A6265666F72657B636F6E74656E743A27273B706F736974696F6E3A6162736F6C7574653B6D617267696E3A3870783B746F703A303B6C6566743A303B77696474683A3470783B6865696768743A3470783B626F726465722D72';
wwv_flow_api.g_varchar2_table(62) := '61646975733A313030253B6261636B67726F756E642D636F6C6F723A7267626128302C302C302C2E35297D2E666F732D416C6572742D2D70616765202E612D4E6F74696669636174696F6E2D6974656D202E612D427574746F6E2D2D6E6F746966696361';
wwv_flow_api.g_varchar2_table(63) := '74696F6E7B70616464696E673A3270783B6F7061636974793A2E37353B766572746963616C2D616C69676E3A746F707D2E666F732D416C6572742D2D70616765202E68746D6C64624F72614572727B6D617267696E2D746F703A2E3872656D3B64697370';
wwv_flow_api.g_varchar2_table(64) := '6C61793A626C6F636B3B666F6E742D73697A653A312E3172656D3B6C696E652D6865696768743A312E3672656D3B666F6E742D66616D696C793A274D656E6C6F272C27436F6E736F6C6173272C6D6F6E6F73706163652C73657269663B77686974652D73';
wwv_flow_api.g_varchar2_table(65) := '706163653A7072652D6C696E657D2E666F732D416C6572742D2D61636365737369626C6548656164696E67202E666F732D416C6572742D7469746C657B626F726465723A303B636C69703A726563742830203020302030293B6865696768743A3170783B';
wwv_flow_api.g_varchar2_table(66) := '6D617267696E3A2D3170783B6F766572666C6F773A68696464656E3B70616464696E673A303B706F736974696F6E3A6162736F6C7574653B77696474683A3170787D2E666F732D416C6572742D2D72656D6F766548656164696E67202E666F732D416C65';
wwv_flow_api.g_varchar2_table(67) := '72742D7469746C657B646973706C61793A6E6F6E657D406D6564696120286D61782D77696474683A3438307078297B2E666F732D416C6572742D2D706167657B6D696E2D77696474683A303B6D61782D77696474683A6E6F6E657D2E666F732D416C6572';
wwv_flow_api.g_varchar2_table(68) := '742D2D70616765202E612D4E6F74696669636174696F6E2D6974656D7B666F6E742D73697A653A313270787D7D406D6564696120286D61782D77696474683A3736387078297B2E666F732D416C6572742D2D686F72697A6F6E74616C202E666F732D416C';
wwv_flow_api.g_varchar2_table(69) := '6572742D7469746C657B666F6E742D73697A653A312E3872656D7D7D2E666F732D416C657274202E742D49636F6E2E69636F6E2D636C6F73653A6265666F72657B666F6E742D66616D696C793A22617065782D352D69636F6E2D666F6E74223B64697370';
wwv_flow_api.g_varchar2_table(70) := '6C61793A696E6C696E652D626C6F636B3B766572746963616C2D616C69676E3A746F703B6C696E652D6865696768743A313670783B666F6E742D73697A653A313670783B636F6E74656E743A225C65306132227D2E666F7374722D746F702D63656E7465';
wwv_flow_api.g_varchar2_table(71) := '727B746F703A312E3672656D3B72696768743A303B77696474683A313030257D2E666F7374722D626F74746F6D2D63656E7465727B626F74746F6D3A312E3672656D3B72696768743A303B77696474683A313030257D2E666F7374722D746F702D726967';
wwv_flow_api.g_varchar2_table(72) := '68747B746F703A312E3672656D3B72696768743A312E3672656D7D2E666F7374722D746F702D6C6566747B746F703A312E3672656D3B6C6566743A312E3672656D7D2E666F7374722D626F74746F6D2D72696768747B72696768743A312E3672656D3B62';
wwv_flow_api.g_varchar2_table(73) := '6F74746F6D3A312E3672656D7D2E666F7374722D626F74746F6D2D6C6566747B626F74746F6D3A312E3672656D3B6C6566743A312E3672656D7D2E666F7374722D636F6E7461696E65727B706F736974696F6E3A66697865643B7A2D696E6465783A3939';
wwv_flow_api.g_varchar2_table(74) := '393939393B706F696E7465722D6576656E74733A6E6F6E657D2E666F7374722D636F6E7461696E65723E6469767B706F696E7465722D6576656E74733A6175746F7D2E666F7374722D636F6E7461696E65722E666F7374722D626F74746F6D2D63656E74';
wwv_flow_api.g_varchar2_table(75) := '65723E6469762C2E666F7374722D636F6E7461696E65722E666F7374722D746F702D63656E7465723E6469767B6D617267696E2D6C6566743A6175746F3B6D617267696E2D72696768743A6175746F7D2E666F7374722D70726F67726573737B706F7369';
wwv_flow_api.g_varchar2_table(76) := '74696F6E3A6162736F6C7574653B626F74746F6D3A303B6865696768743A3470783B6261636B67726F756E642D636F6C6F723A233030303B6F7061636974793A2E347D68746D6C3A6E6F74282E752D52544C29202E666F7374722D70726F67726573737B';
wwv_flow_api.g_varchar2_table(77) := '6C6566743A303B626F726465722D626F74746F6D2D6C6566742D7261646975733A2E3472656D7D68746D6C2E752D52544C202E666F7374722D70726F67726573737B72696768743A303B626F726465722D626F74746F6D2D72696768742D726164697573';
wwv_flow_api.g_varchar2_table(78) := '3A2E3472656D7D406D6564696120286D61782D77696474683A3438307078297B2E666F7374722D636F6E7461696E65727B6C6566743A312E3672656D3B72696768743A312E3672656D7D7D0A2F2A2320736F757263654D617070696E6755524C3D666F73';
wwv_flow_api.g_varchar2_table(79) := '74722E6373732E6D61702A2F';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(729779902845330292)
,p_plugin_id=>wwv_flow_api.id(441585844511348477)
,p_file_name=>'css/fostr.min.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A0A202A2052544C20737570706F72742073686F756C6420626520646F6E6520696E20637373206F6E6C792E20636C61737320752D52544C20657869737473206F6E2074686520626F6479207768656E206170657820697320696E2052544C206D6F64';
wwv_flow_api.g_varchar2_table(2) := '652E0A202A204E6F7465207468617420746869732073686F756C64206F6E6C792061666665637420656C656D656E74732077697468696E20746865206E6F74696669636174696F6E2C206E6F742074686520706F736974696F6E696E67206F6620746865';
wwv_flow_api.g_varchar2_table(3) := '2061637475616C206E6F74696669636174696F6E2E0A202A20546869732069732074616B656E2063617265206F66206279206120706C75672D696E2073657474696E67732E0A202A0A202A2F0A0A2F2A0A202A20466F7374720A202A20436F7079726967';
wwv_flow_api.g_varchar2_table(4) := '687420323032300A202A20417574686F72733A2053746566616E20446F6272650A202A0A202A204372656469747320666F722074686520626173652076657273696F6E20676F20746F3A2068747470733A2F2F6769746875622E636F6D2F436F64655365';
wwv_flow_api.g_varchar2_table(5) := '76656E2F746F617374720A202A204F726967696E616C20417574686F72733A204A6F686E20506170612C2048616E7320466AC3A46C6C656D61726B2C20616E642054696D2046657272656C6C2E0A202A204152494120537570706F72743A204772657461';
wwv_flow_api.g_varchar2_table(6) := '204B7261667369670A202A0A202A20416C6C205269676874732052657365727665642E0A202A205573652C20726570726F64756374696F6E2C20646973747269627574696F6E2C20616E64206D6F64696669636174696F6E206F66207468697320636F64';
wwv_flow_api.g_varchar2_table(7) := '65206973207375626A65637420746F20746865207465726D7320616E640A202A20636F6E646974696F6E73206F6620746865204D4954206C6963656E73652C20617661696C61626C6520617420687474703A2F2F7777772E6F70656E736F757263652E6F';
wwv_flow_api.g_varchar2_table(8) := '72672F6C6963656E7365732F6D69742D6C6963656E73652E7068700A202A0A202A2050726F6A6563743A2068747470733A2F2F6769746875622E636F6D2F666F65782D6F70656E2D736F757263652F666F7374720A202A2F0A77696E646F772E666F7374';
wwv_flow_api.g_varchar2_table(9) := '72203D202866756E6374696F6E2829207B0A0A2020202076617220434F4E5441494E45525F434C415353203D2027666F7374722D636F6E7461696E6572273B0A0A2020202076617220746F61737454797065203D207B0A20202020202020207375636365';
wwv_flow_api.g_varchar2_table(10) := '73733A202773756363657373272C0A2020202020202020696E666F3A2027696E666F272C0A20202020202020207761726E696E673A20277761726E696E67272C0A20202020202020206572726F723A20276572726F72270A202020207D3B0A0A20202020';
wwv_flow_api.g_varchar2_table(11) := '7661722069636F6E436C6173736573203D207B0A2020202020202020737563636573733A202766612D636865636B2D636972636C65272C0A2020202020202020696E666F3A202766612D696E666F2D636972636C65272C0A20202020202020207761726E';
wwv_flow_api.g_varchar2_table(12) := '696E673A202766612D6578636C616D6174696F6E2D747269616E676C65272C0A20202020202020206572726F723A202766612D74696D65732D636972636C65270A202020207D3B0A0A2020202076617220636F6E7461696E657273203D207B7D3B0A2020';
wwv_flow_api.g_varchar2_table(13) := '20207661722070726576696F7573546F617374203D207B7D3B0A0A2020202066756E6374696F6E206E6F746966795479706528747970652C206D6573736167652C207469746C652C206F7074696F6E7329207B0A0A20202020202020207661722066696E';
wwv_flow_api.g_varchar2_table(14) := '616C4F7074696F6E73203D20242E657874656E64287B7D2C207B0A2020202020202020202020206469736D6973733A205B276F6E436C69636B272C20276F6E427574746F6E275D2C2020202F2F207768656E20746F206469736D69737320746865206E6F';
wwv_flow_api.g_varchar2_table(15) := '74696669636174696F6E0A2020202020202020202020206469736D69737341667465723A206E756C6C2C20202020202020202020202020202020202F2F2061206E756D62657220696E206D696C6C697365636F6E64732061667465722077686963682074';
wwv_flow_api.g_varchar2_table(16) := '6865206E6F74696669636174696F6E2073686F756C64206265206175746F6D61746963616C6C792072656D6F7665642E20686F766572696E67206F7220636C69636B696E6720746865206E6F74696669636174696F6E2073746F70732074686973206576';
wwv_flow_api.g_varchar2_table(17) := '656E740A2020202020202020202020206E65776573744F6E546F703A20747275652C2020202020202020202020202020202020202F2F2061646420746F2074686520746F70206F6620746865206C6973740A20202020202020202020202070726576656E';
wwv_flow_api.g_varchar2_table(18) := '744475706C6963617465733A2066616C73652C20202020202020202020202F2F20646F206E6F742073686F7720746865206E6F74696669636174696F6E20696620697420686173207468652073616D65207469746C6520616E64206D6573736167652061';
wwv_flow_api.g_varchar2_table(19) := '7320746865206C617374206F6E6520616E6420696620746865206C617374206F6E65206973207374696C6C2076697369626C650A20202020202020202020202065736361706548746D6C3A20747275652C20202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(20) := '2F2F207768657468657220746F2065736361706520746865207469746C6520616E64206D6573736167650A202020202020202020202020706F736974696F6E3A2027746F702D7269676874272C20202020202020202020202020202F2F206F6E65206F66';
wwv_flow_api.g_varchar2_table(21) := '20363A205B746F707C626F74746F6D5D2D5B72696768747C63656E7465727C6C6566745D0A20202020202020202020202069636F6E436C6173733A206E756C6C2C20202020202020202020202020202020202020202F2F207768656E206C65667420746F';
wwv_flow_api.g_varchar2_table(22) := '206E756C6C2C2069742077696C6C2062652064656661756C74656420746F2074686520636F72726573706F6E64696E672069636F6E2066726F6D2069636F6E436C61737365730A202020202020202020202020636C656172416C6C3A2066616C73652020';
wwv_flow_api.g_varchar2_table(23) := '202020202020202020202020202020202020202F2F207472756520746F20636C65617220616C6C206E6F74696669636174696F6E732066697273740A20202020202020207D2C206F7074696F6E73293B0A0A20202020202020202F2F2069662074686520';
wwv_flow_api.g_varchar2_table(24) := '6D6573736167652061747472696275746520697320616E206F626A6563740A202020202020202069662028747970656F66206D657373616765203D3D3D20276F626A6563742729207B0A2020202020202020202020206D6573736167652E74797065203D';
wwv_flow_api.g_varchar2_table(25) := '20747970653B0A20202020202020202020202072657475726E206E6F7469667928242E657874656E642866696E616C4F7074696F6E732C207B0A20202020202020202020202020202020747970653A20747970650A2020202020202020202020207D2C20';
wwv_flow_api.g_varchar2_table(26) := '6D65737361676529293B0A20202020202020207D20656C736520696620286D657373616765207C7C207469746C6529207B0A20202020202020202020202069662028217469746C65202626206D65737361676529207B0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(27) := '2020207469746C65203D206D6573736167653B0A202020202020202020202020202020206D657373616765203D20756E646566696E65643B0A2020202020202020202020207D0A20202020202020202020202072657475726E206E6F7469667928242E65';
wwv_flow_api.g_varchar2_table(28) := '7874656E64287B7D2C7B0A20202020202020202020202020202020747970653A20747970652C0A202020202020202020202020202020206D6573736167653A206D6573736167652C0A202020202020202020202020202020207469746C653A207469746C';
wwv_flow_api.g_varchar2_table(29) := '650A2020202020202020202020207D2C2066696E616C4F7074696F6E7329293B0A20202020202020207D20656C7365207B0A202020202020202020202020617065782E64656275672E696E666F2827666F7374723A206E6F207469746C65206F72206D65';
wwv_flow_api.g_varchar2_table(30) := '7373616765207761732070726F76696465642E206E6F742073686F77696E67206E6F74696669636174696F6E2E27293B0A20202020202020207D0A202020207D0A0A2020202066756E6374696F6E2073756363657373286D6573736167652C207469746C';
wwv_flow_api.g_varchar2_table(31) := '652C206F7074696F6E7329207B0A202020202020202072657475726E206E6F746966795479706528746F617374547970652E737563636573732C206D6573736167652C207469746C652C206F7074696F6E73293B0A202020207D0A0A2020202066756E63';
wwv_flow_api.g_varchar2_table(32) := '74696F6E207761726E696E67286D6573736167652C207469746C652C206F7074696F6E7329207B0A202020202020202072657475726E206E6F746966795479706528746F617374547970652E7761726E696E672C206D6573736167652C207469746C652C';
wwv_flow_api.g_varchar2_table(33) := '206F7074696F6E73293B0A202020207D0A0A2020202066756E6374696F6E20696E666F286D6573736167652C207469746C652C206F7074696F6E7329207B0A202020202020202072657475726E206E6F746966795479706528746F617374547970652E69';
wwv_flow_api.g_varchar2_table(34) := '6E666F2C206D6573736167652C207469746C652C206F7074696F6E73293B0A202020207D0A0A2020202066756E6374696F6E206572726F72286D6573736167652C207469746C652C206F7074696F6E7329207B0A202020202020202072657475726E206E';
wwv_flow_api.g_varchar2_table(35) := '6F746966795479706528746F617374547970652E6572726F722C206D6573736167652C207469746C652C206F7074696F6E73293B0A202020207D0A0A2020202066756E6374696F6E20636C656172416C6C2829207B0A20202020202020202428272E2720';
wwv_flow_api.g_varchar2_table(36) := '2B20434F4E5441494E45525F434C415353292E6368696C6472656E28292E72656D6F766528293B0A202020207D0A0A202020202F2F20696E7465726E616C2066756E6374696F6E730A0A2020202066756E6374696F6E20676574436F6E7461696E657228';
wwv_flow_api.g_varchar2_table(37) := '706F736974696F6E29207B0A0A202020202020202066756E6374696F6E20637265617465436F6E7461696E657228706F736974696F6E29207B0A2020202020202020202020207661722024636F6E7461696E6572203D202428273C6469762F3E27292E61';
wwv_flow_api.g_varchar2_table(38) := '6464436C6173732827666F7374722D27202B20706F736974696F6E292E616464436C61737328434F4E5441494E45525F434C415353293B0A202020202020202020202020242827626F647927292E617070656E642824636F6E7461696E6572293B0A2020';
wwv_flow_api.g_varchar2_table(39) := '20202020202020202020636F6E7461696E6572735B706F736974696F6E5D203D2024636F6E7461696E65723B0A20202020202020202020202072657475726E2024636F6E7461696E65723B0A20202020202020207D0A0A20202020202020207265747572';
wwv_flow_api.g_varchar2_table(40) := '6E20636F6E7461696E6572735B706F736974696F6E5D207C7C20637265617465436F6E7461696E657228706F736974696F6E293B0A202020207D0A0A2020202066756E6374696F6E206E6F7469667928636F6E66696729207B0A0A202020202020202076';
wwv_flow_api.g_varchar2_table(41) := '61722024636F6E7461696E6572203D20676574436F6E7461696E657228636F6E6669672E706F736974696F6E293B0A0A2020202020202020766172206469736D6973734F6E436C69636B203D20636F6E6669672E6469736D6973732E696E636C75646573';
wwv_flow_api.g_varchar2_table(42) := '28276F6E436C69636B27293B0A2020202020202020766172206469736D6973734F6E427574746F6E203D20636F6E6669672E6469736D6973732E696E636C7564657328276F6E427574746F6E27293B0A0A20202020202020202F2A0A2020202020202020';
wwv_flow_api.g_varchar2_table(43) := '3C64697620636C6173733D22666F732D416C65727420666F732D416C6572742D2D686F72697A6F6E74616C20666F732D416C6572742D2D7061676520666F732D416C6572742D2D737563636573732220726F6C653D22616C657274223E0A202020202020';
wwv_flow_api.g_varchar2_table(44) := '2020202020203C64697620636C6173733D22666F732D416C6572742D77726170223E0A202020202020202020202020202020203C64697620636C6173733D22666F732D416C6572742D69636F6E223E0A2020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(45) := '3C7370616E20636C6173733D22742D49636F6E2066612066612D636865636B2D636972636C65223E3C2F7370616E3E0A202020202020202020202020202020203C2F6469763E0A202020202020202020202020202020203C64697620636C6173733D2266';
wwv_flow_api.g_varchar2_table(46) := '6F732D416C6572742D636F6E74656E74223E0A20202020202020202020202020202020202020203C683220636C6173733D22666F732D416C6572742D7469746C65223E3C2F68323E0A20202020202020202020202020202020202020203C64697620636C';
wwv_flow_api.g_varchar2_table(47) := '6173733D22666F732D416C6572742D626F6479223E3C2F6469763E0A202020202020202020202020202020203C2F6469763E0A202020202020202020202020202020203C64697620636C6173733D22666F732D416C6572742D627574746F6E73223E0A20';
wwv_flow_api.g_varchar2_table(48) := '202020202020202020202020202020202020203C627574746F6E20636C6173733D22742D427574746F6E20742D427574746F6E2D2D6E6F554920742D427574746F6E2D2D69636F6E20742D427574746F6E2D2D636C6F7365416C6572742220747970653D';
wwv_flow_api.g_varchar2_table(49) := '22627574746F6E22207469746C653D22436C6F7365204E6F74696669636174696F6E223E3C7370616E20636C6173733D22742D49636F6E2069636F6E2D636C6F7365223E3C2F7370616E3E3C2F627574746F6E3E0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(50) := '203C2F6469763E0A2020202020202020202020203C2F6469763E0A20202020202020203C2F6469763E0A20202020202020202A2F0A0A20202020202020207661722074797065436C617373203D207B0A2020202020202020202020202273756363657373';
wwv_flow_api.g_varchar2_table(51) := '223A2022666F732D416C6572742D2D73756363657373222C0A202020202020202020202020226572726F72223A2022666F732D416C6572742D2D64616E676572222C0A202020202020202020202020227761726E696E67223A2022666F732D416C657274';
wwv_flow_api.g_varchar2_table(52) := '2D2D7761726E696E67222C0A20202020202020202020202022696E666F223A2022666F732D416C6572742D2D696E666F220A20202020202020207D3B0A0A20202020202020207661722024746F617374456C656D656E74203D202428273C64697620636C';
wwv_flow_api.g_varchar2_table(53) := '6173733D22666F732D416C65727420666F732D416C6572742D2D686F72697A6F6E74616C20666F732D416C6572742D2D706167652027202B2074797065436C6173735B636F6E6669672E747970655D202B20272220726F6C653D22616C657274223E3C2F';
wwv_flow_api.g_varchar2_table(54) := '6469763E27293B0A20202020202020207661722024746F61737457726170203D202428273C64697620636C6173733D22666F732D416C6572742D77726170223E27293B0A2020202020202020766172202469636F6E57726170203D202428273C64697620';
wwv_flow_api.g_varchar2_table(55) := '636C6173733D22666F732D416C6572742D69636F6E223E3C2F6469763E27293B0A2020202020202020766172202469636F6E456C656D203D202428273C7370616E20636C6173733D22742D49636F6E2066612027202B2028636F6E6669672E69636F6E43';
wwv_flow_api.g_varchar2_table(56) := '6C617373207C7C2069636F6E436C61737365735B636F6E6669672E747970655D29202B2027223E3C2F7370616E3E27293B0A20202020202020207661722024636F6E74656E74456C656D203D202428273C64697620636C6173733D22666F732D416C6572';
wwv_flow_api.g_varchar2_table(57) := '742D636F6E74656E74223E3C2F6469763E27293B0A202020202020202076617220247469746C65456C656D656E74203D202428273C683220636C6173733D22666F732D416C6572742D7469746C65223E3C2F68323E27293B0A2020202020202020766172';
wwv_flow_api.g_varchar2_table(58) := '20246D657373616765456C656D656E74203D202428273C64697620636C6173733D22666F732D416C6572742D626F6479223E3C2F6469763E27293B0A20202020202020207661722024627574746F6E57726170706572203D202428273C64697620636C61';
wwv_flow_api.g_varchar2_table(59) := '73733D22666F732D416C6572742D627574746F6E73223E3C2F6469763E27293B0A20202020202020207661722024636C6F7365456C656D656E743B0A0A2020202020202020696620286469736D6973734F6E427574746F6E29207B0A2020202020202020';
wwv_flow_api.g_varchar2_table(60) := '2020202024636C6F7365456C656D656E74203D202428273C627574746F6E20636C6173733D22742D427574746F6E20742D427574746F6E2D2D6E6F554920742D427574746F6E2D2D69636F6E20742D427574746F6E2D2D636C6F7365416C657274222074';
wwv_flow_api.g_varchar2_table(61) := '7970653D22627574746F6E22207469746C653D22436C6F7365204E6F74696669636174696F6E223E3C7370616E20636C6173733D22742D49636F6E2069636F6E2D636C6F7365223E3C2F7370616E3E3C2F627574746F6E3E27293B0A2020202020202020';
wwv_flow_api.g_varchar2_table(62) := '7D0A0A202020202020202024746F617374456C656D656E742E617070656E642824746F61737457726170293B0A202020202020202024746F617374577261702E617070656E64282469636F6E57726170293B0A20202020202020202469636F6E57726170';
wwv_flow_api.g_varchar2_table(63) := '2E617070656E64282469636F6E456C656D293B0A202020202020202024746F617374577261702E617070656E642824636F6E74656E74456C656D293B0A202020202020202024636F6E74656E74456C656D2E617070656E6428247469746C65456C656D65';
wwv_flow_api.g_varchar2_table(64) := '6E74293B0A202020202020202024636F6E74656E74456C656D2E617070656E6428246D657373616765456C656D656E74293B0A202020202020202024746F617374577261702E617070656E642824627574746F6E57726170706572293B0A0A2020202020';
wwv_flow_api.g_varchar2_table(65) := '202020696620286469736D6973734F6E427574746F6E29207B0A20202020202020202020202024627574746F6E577261707065722E617070656E642824636C6F7365456C656D656E74293B0A20202020202020207D0A0A20202020202020202F2F207365';
wwv_flow_api.g_varchar2_table(66) := '7474696E6720746865207469746C650A2020202020202020766172207469746C65203D20636F6E6669672E7469746C653B0A2020202020202020696620287469746C6529207B0A20202020202020202020202069662028636F6E6669672E657363617065';
wwv_flow_api.g_varchar2_table(67) := '48746D6C29207B0A202020202020202020202020202020207469746C65203D20617065782E7574696C2E65736361706548544D4C287469746C65293B0A2020202020202020202020207D0A202020202020202020202020247469746C65456C656D656E74';
wwv_flow_api.g_varchar2_table(68) := '2E617070656E64287469746C65293B0A20202020202020207D20656C7365207B0A202020202020202020202020247469746C65456C656D656E742E72656D6F766528293B0A20202020202020207D0A0A20202020202020202F2F73657474696E67207468';
wwv_flow_api.g_varchar2_table(69) := '65206D6573736167650A2020202020202020766172206D657373616765203D20636F6E6669672E6D6573736167653B0A2020202020202020696620286D65737361676529207B0A20202020202020202020202069662028636F6E6669672E657363617065';
wwv_flow_api.g_varchar2_table(70) := '48746D6C20262620747970656F66206D657373616765203D3D2027737472696E6727297B0A202020202020202020202020202020206D657373616765203D20617065782E7574696C2E65736361706548544D4C286D657373616765293B0A202020202020';
wwv_flow_api.g_varchar2_table(71) := '2020202020207D0A202020202020202020202020246D657373616765456C656D656E742E617070656E64286D657373616765293B0A20202020202020207D0A0A20202020202020202F2F2061766F6964696E67206475706C6963617465732C2062757420';
wwv_flow_api.g_varchar2_table(72) := '6F6E6C7920636F6E7365637574697665206F6E65730A202020202020202069662028636F6E6669672E70726576656E744475706C6963617465732026262070726576696F7573546F6173742026262070726576696F7573546F6173742E24656C656D2026';
wwv_flow_api.g_varchar2_table(73) := '262070726576696F7573546F6173742E24656C656D2E697328273A76697369626C65272929207B0A2020202020202020202020206966202870726576696F7573546F6173742E7469746C65203D3D207469746C652026262070726576696F7573546F6173';
wwv_flow_api.g_varchar2_table(74) := '742E6D657373616765203D3D206D65737361676529207B0A2020202020202020202020202020202072657475726E3B0A2020202020202020202020207D0A20202020202020207D0A0A202020202020202070726576696F7573546F617374203D207B0A20';
wwv_flow_api.g_varchar2_table(75) := '202020202020202020202024656C656D3A2024746F617374456C656D656E742C0A2020202020202020202020207469746C653A207469746C652C0A2020202020202020202020206D6573736167653A206D6573736167650A20202020202020207D3B0A0A';
wwv_flow_api.g_varchar2_table(76) := '20202020202020202F2F206F7074696F6E616C6C7920636C65617220616C6C206D657373616765732066697273740A202020202020202069662028636F6E6669672E636C656172416C6C29207B0A202020202020202020202020636C656172416C6C2829';
wwv_flow_api.g_varchar2_table(77) := '3B0A20202020202020207D0A20202020202020202F2F206164647320746865206E6F74696669636174696F6E20746F2074686520636F6E7461696E65720A202020202020202069662028636F6E6669672E6E65776573744F6E546F7029207B0A20202020';
wwv_flow_api.g_varchar2_table(78) := '202020202020202024636F6E7461696E65722E70726570656E642824746F617374456C656D656E74293B0A20202020202020207D20656C7365207B0A20202020202020202020202024636F6E7461696E65722E617070656E642824746F617374456C656D';
wwv_flow_api.g_varchar2_table(79) := '656E74293B0A20202020202020207D0A0A20202020202020202F2F2073657474696E672074686520636F727265637420415249412076616C75650A2020202020202020766172206172696156616C75653B0A20202020202020207377697463682028636F';
wwv_flow_api.g_varchar2_table(80) := '6E6669672E7479706529207B0A20202020202020202020202063617365202773756363657373273A0A202020202020202020202020636173652027696E666F273A0A202020202020202020202020202020206172696156616C7565203D2027706F6C6974';
wwv_flow_api.g_varchar2_table(81) := '65273B0A20202020202020202020202020202020627265616B3B0A20202020202020202020202064656661756C743A0A202020202020202020202020202020206172696156616C7565203D2027617373657274697665273B0A20202020202020207D0A20';
wwv_flow_api.g_varchar2_table(82) := '2020202020202024746F617374456C656D656E742E617474722827617269612D6C697665272C206172696156616C7565293B0A0A20202020202020202F2F73657474696E672074696D657220616E642070726F6772657373206261720A20202020202020';
wwv_flow_api.g_varchar2_table(83) := '20766172202470726F6772657373456C656D656E74203D202428273C6469762F3E27293B0A202020202020202069662028636F6E6669672E6469736D6973734166746572203E203029207B0A2020202020202020202020202470726F6772657373456C65';
wwv_flow_api.g_varchar2_table(84) := '6D656E742E616464436C6173732827666F7374722D70726F677265737327293B0A20202020202020202020202024746F617374456C656D656E742E617070656E64282470726F6772657373456C656D656E74293B0A0A2020202020202020202020207661';
wwv_flow_api.g_varchar2_table(85) := '722074696D656F75744964203D2073657454696D656F75742866756E6374696F6E2829207B0A2020202020202020202020202020202024746F617374456C656D656E742E72656D6F766528293B0A2020202020202020202020207D2C20636F6E6669672E';
wwv_flow_api.g_varchar2_table(86) := '6469736D6973734166746572293B0A2020202020202020202020207661722070726F67726573735374617274416E696D44656C6179203D203130303B0A0A2020202020202020202020202470726F6772657373456C656D656E742E637373287B0A202020';
wwv_flow_api.g_varchar2_table(87) := '20202020202020202020202020277769647468273A202731303025272C0A20202020202020202020202020202020277472616E736974696F6E273A202777696474682027202B202828636F6E6669672E6469736D6973734166746572202D2070726F6772';
wwv_flow_api.g_varchar2_table(88) := '6573735374617274416E696D44656C6179292F3130303029202B202773206C696E656172270A2020202020202020202020207D293B0A20202020202020202020202073657454696D656F75742866756E6374696F6E28297B0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(89) := '20202020202470726F6772657373456C656D656E742E63737328277769647468272C20273027293B0A2020202020202020202020207D2C2070726F67726573735374617274416E696D44656C6179293B0A0A2020202020202020202020202F2F206F6E20';
wwv_flow_api.g_varchar2_table(90) := '686F766572206F7220636C69636B2C2072656D6F7665207468652074696D657220616E642070726F6772657373206261720A20202020202020202020202024746F617374456C656D656E742E6F6E28276D6F7573656F76657220636C69636B272C206675';
wwv_flow_api.g_varchar2_table(91) := '6E6374696F6E2829207B0A20202020202020202020202020202020636C65617254696D656F75742874696D656F75744964293B0A202020202020202020202020202020202470726F6772657373456C656D656E742E72656D6F766528293B0A2020202020';
wwv_flow_api.g_varchar2_table(92) := '202020202020207D293B0A20202020202020207D0A0A20202020202020202F2F68616E646C696E6720616E79206576656E74730A2020202020202020696620286469736D6973734F6E436C69636B29207B0A20202020202020202020202024746F617374';
wwv_flow_api.g_varchar2_table(93) := '456C656D656E742E6F6E2827636C69636B272C2066756E6374696F6E286576656E7429207B0A202020202020202020202020202020202F2F20646F206E6F74206469736D6973732069662074686520636C69636B656420656C656D656E7420697320616E';
wwv_flow_api.g_varchar2_table(94) := '20616E63686F72206F72206120627574746F6E0A202020202020202020202020202020206966285B2741272C2027425554544F4E275D2E696E636C756465732824286576656E742E746172676574292E70726F7028276E6F64654E616D65272929297B0A';
wwv_flow_api.g_varchar2_table(95) := '202020202020202020202020202020202020202072657475726E3B0A202020202020202020202020202020207D0A0A202020202020202020202020202020202F2F20646F206E6F74206469736D6973732069662074686520757365722069732073656C65';
wwv_flow_api.g_varchar2_table(96) := '6374696E6720746578740A202020202020202020202020202020207661722073656C656374696F6E203D2077696E646F772E67657453656C656374696F6E28293B0A202020202020202020202020202020206966282073656C656374696F6E2026260A20';
wwv_flow_api.g_varchar2_table(97) := '2020202020202020202020202020202020202073656C656374696F6E2E74797065203D3D202752616E6765272026260A202020202020202020202020202020202020202073656C656374696F6E2E616E63686F724E6F64652026260A2020202020202020';
wwv_flow_api.g_varchar2_table(98) := '202020202020202020202020242873656C656374696F6E2E616E63686F724E6F64652C2024746F617374456C656D656E74292E6C656E677468203E2030297B0A202020202020202020202020202020202020202072657475726E3B0A2020202020202020';
wwv_flow_api.g_varchar2_table(99) := '20202020202020207D0A0A2020202020202020202020202020202024746F617374456C656D656E742E72656D6F766528293B0A2020202020202020202020207D293B0A20202020202020207D0A0A2020202020202020696620286469736D6973734F6E42';
wwv_flow_api.g_varchar2_table(100) := '7574746F6E29207B0A20202020202020202020202024636C6F7365456C656D656E742E6F6E2827636C69636B272C2066756E6374696F6E2829207B0A2020202020202020202020202020202024746F617374456C656D656E742E72656D6F766528293B0A';
wwv_flow_api.g_varchar2_table(101) := '2020202020202020202020207D293B0A20202020202020207D0A0A20202020202020202F2F20706572686170732074686520646576656C6F7065722077616E747320746F20646F20736F6D657468696E67206164646974696F6E616C6C79207768656E20';
wwv_flow_api.g_varchar2_table(102) := '746865206E6F74696669636174696F6E20697320636C69636B65640A202020202020202069662028747970656F6620636F6E6669672E6F6E636C69636B203D3D3D202766756E6374696F6E2729207B0A20202020202020202020202024746F617374456C';
wwv_flow_api.g_varchar2_table(103) := '656D656E742E6F6E2827636C69636B272C20636F6E6669672E6F6E636C69636B293B0A202020202020202020202020696620286469736D6973734F6E427574746F6E292024636C6F7365456C656D656E742E6F6E2827636C69636B272C20636F6E666967';
wwv_flow_api.g_varchar2_table(104) := '2E6F6E636C69636B293B0A20202020202020207D0A0A202020202020202072657475726E2024746F617374456C656D656E743B0A202020207D0A0A2020202072657475726E207B0A2020202020202020737563636573733A20737563636573732C0A2020';
wwv_flow_api.g_varchar2_table(105) := '202020202020696E666F3A20696E666F2C0A20202020202020207761726E696E673A207761726E696E672C0A20202020202020206572726F723A206572726F722C0A2020202020202020636C656172416C6C3A20636C656172416C6C2C0A202020202020';
wwv_flow_api.g_varchar2_table(106) := '202076657273696F6E3A202732302E322E30270A202020207D3B0A0A7D2928293B0A0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(729780260828330293)
,p_plugin_id=>wwv_flow_api.id(441585844511348477)
,p_file_name=>'js/fostr.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '7B2276657273696F6E223A332C22736F7572636573223A5B22666F7374722E6A73225D2C226E616D6573223A5B2277696E646F77222C22666F737472222C22434F4E5441494E45525F434C415353222C22746F61737454797065222C2269636F6E436C61';
wwv_flow_api.g_varchar2_table(2) := '73736573222C2273756363657373222C22696E666F222C227761726E696E67222C226572726F72222C22636F6E7461696E657273222C2270726576696F7573546F617374222C226E6F7469667954797065222C2274797065222C226D657373616765222C';
wwv_flow_api.g_varchar2_table(3) := '227469746C65222C226F7074696F6E73222C2266696E616C4F7074696F6E73222C2224222C22657874656E64222C226469736D697373222C226469736D6973734166746572222C226E65776573744F6E546F70222C2270726576656E744475706C696361';
wwv_flow_api.g_varchar2_table(4) := '746573222C2265736361706548746D6C222C22706F736974696F6E222C2269636F6E436C617373222C22636C656172416C6C222C226E6F74696679222C22756E646566696E6564222C2261706578222C226465627567222C226368696C6472656E222C22';
wwv_flow_api.g_varchar2_table(5) := '72656D6F7665222C22636F6E666967222C2224636C6F7365456C656D656E74222C2224636F6E7461696E6572222C22616464436C617373222C22617070656E64222C22637265617465436F6E7461696E6572222C226469736D6973734F6E436C69636B22';
wwv_flow_api.g_varchar2_table(6) := '2C22696E636C75646573222C226469736D6973734F6E427574746F6E222C2224746F617374456C656D656E74222C2224746F61737457726170222C222469636F6E57726170222C222469636F6E456C656D222C2224636F6E74656E74456C656D222C2224';
wwv_flow_api.g_varchar2_table(7) := '7469746C65456C656D656E74222C22246D657373616765456C656D656E74222C2224627574746F6E57726170706572222C227574696C222C2265736361706548544D4C222C2224656C656D222C226973222C226172696156616C7565222C227072657065';
wwv_flow_api.g_varchar2_table(8) := '6E64222C2261747472222C222470726F6772657373456C656D656E74222C2274696D656F75744964222C2273657454696D656F7574222C22637373222C227769647468222C227472616E736974696F6E222C226F6E222C22636C65617254696D656F7574';
wwv_flow_api.g_varchar2_table(9) := '222C226576656E74222C22746172676574222C2270726F70222C2273656C656374696F6E222C2267657453656C656374696F6E222C22616E63686F724E6F6465222C226C656E677468222C226F6E636C69636B222C2276657273696F6E225D2C226D6170';
wwv_flow_api.g_varchar2_table(10) := '70696E6773223A224141734241412C4F41414F432C4D4141512C574145582C49414149432C4541416B422C6B4241456C42432C454143532C55414454412C4541454D2C4F41464E412C454147532C55414854412C4541494F2C51414750432C454141632C';
wwv_flow_api.g_varchar2_table(11) := '43414364432C514141532C6B42414354432C4B41414D2C694241434E432C514141532C3042414354432C4D41414F2C6D42414750432C454141612C47414362432C45414167422C47414570422C53414153432C45414157432C4541414D432C4541415343';
wwv_flow_api.g_varchar2_table(12) := '2C4541414F432C47414574432C49414149432C45414165432C45414145432C4F41414F2C474141492C4341433542432C514141532C434141432C554141572C5941437242432C614141632C4B414364432C614141612C45414362432C6D4241416D422C45';
wwv_flow_api.g_varchar2_table(13) := '41436E42432C594141592C4541435A432C534141552C59414356432C554141572C4B414358432C554141552C47414358582C474147482C4D414175422C694241415A462C47414350412C45414151442C4B41414F412C45414352652C4541414F562C4541';
wwv_flow_api.g_varchar2_table(14) := '4145432C4F41414F462C454141632C4341436A434A2C4B41414D412C47414350432C4B414349412C47414157432C49414362412C47414153442C49414356432C45414151442C45414352412C4F414155652C47414550442C4541414F562C45414145432C';
wwv_flow_api.g_varchar2_table(15) := '4F41414F2C474141472C43414374424E2C4B41414D412C4541434E432C51414153412C45414354432C4D41414F412C47414352452C55414548612C4B41414B432C4D41414D78422C4B41414B2C7345416F4278422C534141536F422C4941434C542C4541';
wwv_flow_api.g_varchar2_table(16) := '41452C6F4241417542632C57414157432C5341694278432C534141534C2C4541414F4D2C4741455A2C4941646B42542C45416D4464552C4541724341432C47416463582C45416359532C4541414F542C53414C3942662C45414157652C4941506C422C53';
wwv_flow_api.g_varchar2_table(17) := '41417942412C47414372422C49414149572C454141616C422C454141452C554141556D422C534141532C534141575A2C47414155592C534141536C432C47414770452C4F414641652C454141452C514141516F422C4F41414F462C4741436A4231422C45';
wwv_flow_api.g_varchar2_table(18) := '414157652C47414159572C4541436842412C4541476F42472C4341416742642C49414F3343652C45414169424E2C4541414F642C5141415171422C534141532C5741437A43432C4541416B42522C4541414F642C5141415171422C534141532C59413042';
wwv_flow_api.g_varchar2_table(19) := '3143452C45414167427A422C454141452C2B4441504E2C4341435A5A2C514141572C7142414358472C4D4141532C6F42414354442C514141572C7142414358442C4B4141512C6D424147714632422C4541414F72422C4D4141512C7942414335472B422C';
wwv_flow_api.g_varchar2_table(20) := '4541416131422C454141452C674341436632422C4541415933422C454141452C734341436434422C4541415935422C454141452C32424141364267422C4541414F522C5741416172422C4541415936422C4541414F72422C4F4141532C61414333466B43';
wwv_flow_api.g_varchar2_table(21) := '2C4541416537422C454141452C794341436A4238422C454141674239422C454141452C714341436C422B422C4541416B422F422C454141452C73434143704267432C454141694268432C454141452C794341476E4277422C49414341502C45414167426A';
wwv_flow_api.g_varchar2_table(22) := '422C454141452C304B4147744279422C454141634C2C4F41414F4D2C4741437242412C454141574E2C4F41414F4F2C4741436C42412C45414155502C4F41414F512C4741436A42462C454141574E2C4F41414F532C4741436C42412C45414161542C4F41';
wwv_flow_api.g_varchar2_table(23) := '414F552C4741437042442C45414161542C4F41414F572C47414370424C2C454141574E2C4F41414F592C47414564522C47414341512C454141655A2C4F41414F482C47414931422C4941414970422C454141516D422C4541414F6E422C4D414366412C47';
wwv_flow_api.g_varchar2_table(24) := '4143496D422C4541414F562C61414350542C45414151652C4B41414B71422C4B41414B432C5741415772432C4941456A4369432C45414163562C4F41414F76422C494145724269432C45414163662C5341496C422C494141496E422C454141556F422C45';
wwv_flow_api.g_varchar2_table(25) := '41414F70422C51415372422C47415249412C494143496F422C4541414F562C59414167432C6942414158562C4941433542412C4541415567422C4B41414B71422C4B41414B432C5741415774432C4941456E436D432C4541416742582C4F41414F78422C';
wwv_flow_api.g_varchar2_table(26) := '4D414976426F422C4541414F582C6D42414171425A2C4741416942412C4541416330432C4F41415331432C4541416330432C4D41414D432C474141472C614143764633432C45414163492C4F414153412C474141534A2C45414163472C53414157412C47';
wwv_flow_api.g_varchar2_table(27) := '41446A452C43417742412C4941414979432C4541434A2C4F416E424135432C45414167422C4341435A30432C4D41414F562C4541435035422C4D41414F412C45414350442C51414153412C474149546F422C4541414F502C55414350412C494147414F2C';
wwv_flow_api.g_varchar2_table(28) := '4541414F5A2C59414350632C454141576F422C51414151622C4741456E42502C45414157452C4F41414F4B2C47414B64542C4541414F72422C4D4143582C4941414B2C5541434C2C4941414B2C4F41434430432C454141592C5341435A2C4D41434A2C51';
wwv_flow_api.g_varchar2_table(29) := '414349412C454141592C59414570425A2C45414163632C4B41414B2C59414161462C47414768432C49414149472C4541416D4278432C454141452C5541437A422C4741414967422C4541414F622C614141652C454141472C4341437A4271432C45414169';
wwv_flow_api.g_varchar2_table(30) := '4272422C534141532C6B42414331424D2C454141634C2C4F41414F6F422C47414572422C49414149432C45414159432C594141572C57414376426A422C45414163562C57414366432C4541414F622C6341475671432C4541416942472C494141492C4341';
wwv_flow_api.g_varchar2_table(31) := '436A42432C4D4141532C4F414354432C574141632C5541416137422C4541414F622C61414A542C4B414967442C494141512C614145724675432C594141572C57414350462C4541416942472C494141492C514141532C4F41504C2C4B415737426C422C45';
wwv_flow_api.g_varchar2_table(32) := '41416371422C474141472C6D4241416D422C5741436843432C614141614E2C47414362442C45414169427A422C594171437A422C4F416843494F2C47414341472C4541416371422C474141472C534141532C53414153452C4741452F422C494141472C43';
wwv_flow_api.g_varchar2_table(33) := '4141432C4941414B2C554141557A422C5341415376422C4541414567442C4541414D432C51414151432C4B41414B2C6141416A442C43414B412C49414149432C4541415970452C4F41414F71452C6541436E42442C4741436B422C5341416C42412C4541';
wwv_flow_api.g_varchar2_table(34) := '415578442C4D41435677442C45414155452C5941435672442C454141456D442C45414155452C5741415935422C4741416536422C4F4141532C474149704437422C45414163562C6141496C42532C47414341502C4541416336422C474141472C53414153';
wwv_flow_api.g_varchar2_table(35) := '2C574143744272422C45414163562C59414B512C6D4241416E42432C4541414F75432C5541436439422C4541416371422C474141472C5141415339422C4541414F75432C53414337422F422C4741416942502C4541416336422C474141472C5141415339';
wwv_flow_api.g_varchar2_table(36) := '422C4541414F75432C5541476E4439422C474147582C4D41414F2C4341434872432C51416C4E4A2C5341416942512C45414153432C4541414F432C47414337422C4F41414F4A2C45414157522C4541416D42552C45414153432C4541414F432C49416B4E';
wwv_flow_api.g_varchar2_table(37) := '7244542C4B41334D4A2C534141634F2C45414153432C4541414F432C47414331422C4F41414F4A2C45414157522C4541416742552C45414153432C4541414F432C4941324D6C44522C5141684E4A2C53414169424D2C45414153432C4541414F432C4741';
wwv_flow_api.g_varchar2_table(38) := '4337422C4F41414F4A2C45414157522C4541416D42552C45414153432C4541414F432C4941674E7244502C4D417A4D4A2C534141654B2C45414153432C4541414F432C47414333422C4F41414F4A2C45414157522C4541416942552C45414153432C4541';
wwv_flow_api.g_varchar2_table(39) := '414F432C4941794D6E44572C53414155412C454143562B432C514141532C5541395146222C2266696C65223A22666F7374722E6A73227D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(729780680980330293)
,p_plugin_id=>wwv_flow_api.id(441585844511348477)
,p_file_name=>'js/fostr.js.map'
,p_mime_type=>'application/json'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '77696E646F772E666F7374723D66756E6374696F6E28297B76617220653D22666F7374722D636F6E7461696E6572222C743D2273756363657373222C6E3D22696E666F222C733D227761726E696E67222C693D226572726F72222C6F3D7B737563636573';
wwv_flow_api.g_varchar2_table(2) := '733A2266612D636865636B2D636972636C65222C696E666F3A2266612D696E666F2D636972636C65222C7761726E696E673A2266612D6578636C616D6174696F6E2D747269616E676C65222C6572726F723A2266612D74696D65732D636972636C65227D';
wwv_flow_api.g_varchar2_table(3) := '2C723D7B7D2C613D7B7D3B66756E6374696F6E206328652C742C6E2C73297B76617220693D242E657874656E64287B7D2C7B6469736D6973733A5B226F6E436C69636B222C226F6E427574746F6E225D2C6469736D69737341667465723A6E756C6C2C6E';
wwv_flow_api.g_varchar2_table(4) := '65776573744F6E546F703A21302C70726576656E744475706C6963617465733A21312C65736361706548746D6C3A21302C706F736974696F6E3A22746F702D7269676874222C69636F6E436C6173733A6E756C6C2C636C656172416C6C3A21317D2C7329';
wwv_flow_api.g_varchar2_table(5) := '3B72657475726E226F626A656374223D3D747970656F6620743F28742E747970653D652C7028242E657874656E6428692C7B747970653A657D2C742929293A747C7C6E3F28216E2626742626286E3D742C743D766F69642030292C7028242E657874656E';
wwv_flow_api.g_varchar2_table(6) := '64287B7D2C7B747970653A652C6D6573736167653A742C7469746C653A6E7D2C692929293A766F696420617065782E64656275672E696E666F2822666F7374723A206E6F207469746C65206F72206D657373616765207761732070726F76696465642E20';
wwv_flow_api.g_varchar2_table(7) := '6E6F742073686F77696E67206E6F74696669636174696F6E2E22297D66756E6374696F6E206C28297B2428222E666F7374722D636F6E7461696E657222292E6368696C6472656E28292E72656D6F766528297D66756E6374696F6E20702874297B766172';
wwv_flow_api.g_varchar2_table(8) := '206E2C732C693D286E3D742E706F736974696F6E2C725B6E5D7C7C66756E6374696F6E2874297B766172206E3D2428223C6469762F3E22292E616464436C6173732822666F7374722D222B74292E616464436C6173732865293B72657475726E20242822';
wwv_flow_api.g_varchar2_table(9) := '626F647922292E617070656E64286E292C725B745D3D6E2C6E7D286E29292C633D742E6469736D6973732E696E636C7564657328226F6E436C69636B22292C703D742E6469736D6973732E696E636C7564657328226F6E427574746F6E22292C643D2428';
wwv_flow_api.g_varchar2_table(10) := '273C64697620636C6173733D22666F732D416C65727420666F732D416C6572742D2D686F72697A6F6E74616C20666F732D416C6572742D2D7061676520272B7B737563636573733A22666F732D416C6572742D2D73756363657373222C6572726F723A22';
wwv_flow_api.g_varchar2_table(11) := '666F732D416C6572742D2D64616E676572222C7761726E696E673A22666F732D416C6572742D2D7761726E696E67222C696E666F3A22666F732D416C6572742D2D696E666F227D5B742E747970655D2B272220726F6C653D22616C657274223E3C2F6469';
wwv_flow_api.g_varchar2_table(12) := '763E27292C663D2428273C64697620636C6173733D22666F732D416C6572742D77726170223E27292C753D2428273C64697620636C6173733D22666F732D416C6572742D69636F6E223E3C2F6469763E27292C763D2428273C7370616E20636C6173733D';
wwv_flow_api.g_varchar2_table(13) := '22742D49636F6E20666120272B28742E69636F6E436C6173737C7C6F5B742E747970655D292B27223E3C2F7370616E3E27292C6D3D2428273C64697620636C6173733D22666F732D416C6572742D636F6E74656E74223E3C2F6469763E27292C673D2428';
wwv_flow_api.g_varchar2_table(14) := '273C683220636C6173733D22666F732D416C6572742D7469746C65223E3C2F68323E27292C413D2428273C64697620636C6173733D22666F732D416C6572742D626F6479223E3C2F6469763E27292C773D2428273C64697620636C6173733D22666F732D';
wwv_flow_api.g_varchar2_table(15) := '416C6572742D627574746F6E73223E3C2F6469763E27293B70262628733D2428273C627574746F6E20636C6173733D22742D427574746F6E20742D427574746F6E2D2D6E6F554920742D427574746F6E2D2D69636F6E20742D427574746F6E2D2D636C6F';
wwv_flow_api.g_varchar2_table(16) := '7365416C6572742220747970653D22627574746F6E22207469746C653D22436C6F7365204E6F74696669636174696F6E223E3C7370616E20636C6173733D22742D49636F6E2069636F6E2D636C6F7365223E3C2F7370616E3E3C2F627574746F6E3E2729';
wwv_flow_api.g_varchar2_table(17) := '292C642E617070656E642866292C662E617070656E642875292C752E617070656E642876292C662E617070656E64286D292C6D2E617070656E642867292C6D2E617070656E642841292C662E617070656E642877292C702626772E617070656E64287329';
wwv_flow_api.g_varchar2_table(18) := '3B76617220683D742E7469746C653B683F28742E65736361706548746D6C262628683D617065782E7574696C2E65736361706548544D4C286829292C672E617070656E64286829293A672E72656D6F766528293B76617220793D742E6D6573736167653B';
wwv_flow_api.g_varchar2_table(19) := '69662879262628742E65736361706548746D6C262622737472696E67223D3D747970656F662079262628793D617065782E7574696C2E65736361706548544D4C287929292C412E617070656E64287929292C2128742E70726576656E744475706C696361';
wwv_flow_api.g_varchar2_table(20) := '7465732626612626612E24656C656D2626612E24656C656D2E697328223A76697369626C6522292626612E7469746C653D3D682626612E6D6573736167653D3D7929297B766172206B3B73776974636828613D7B24656C656D3A642C7469746C653A682C';
wwv_flow_api.g_varchar2_table(21) := '6D6573736167653A797D2C742E636C656172416C6C26266C28292C742E6E65776573744F6E546F703F692E70726570656E642864293A692E617070656E642864292C742E74797065297B636173652273756363657373223A6361736522696E666F223A6B';
wwv_flow_api.g_varchar2_table(22) := '3D22706F6C697465223B627265616B3B64656661756C743A6B3D22617373657274697665227D642E617474722822617269612D6C697665222C6B293B76617220623D2428223C6469762F3E22293B696628742E6469736D69737341667465723E30297B62';
wwv_flow_api.g_varchar2_table(23) := '2E616464436C6173732822666F7374722D70726F677265737322292C642E617070656E642862293B76617220543D73657454696D656F7574282866756E6374696F6E28297B642E72656D6F766528297D292C742E6469736D6973734166746572293B622E';
wwv_flow_api.g_varchar2_table(24) := '637373287B77696474683A2231303025222C7472616E736974696F6E3A22776964746820222B28742E6469736D69737341667465722D313030292F3165332B2273206C696E656172227D292C73657454696D656F7574282866756E6374696F6E28297B62';
wwv_flow_api.g_varchar2_table(25) := '2E63737328227769647468222C223022297D292C313030292C642E6F6E28226D6F7573656F76657220636C69636B222C2866756E6374696F6E28297B636C65617254696D656F75742854292C622E72656D6F766528297D29297D72657475726E20632626';
wwv_flow_api.g_varchar2_table(26) := '642E6F6E2822636C69636B222C2866756E6374696F6E2865297B696628215B2241222C22425554544F4E225D2E696E636C75646573282428652E746172676574292E70726F7028226E6F64654E616D65222929297B76617220743D77696E646F772E6765';
wwv_flow_api.g_varchar2_table(27) := '7453656C656374696F6E28293B7426262252616E6765223D3D742E747970652626742E616E63686F724E6F646526262428742E616E63686F724E6F64652C64292E6C656E6774683E307C7C642E72656D6F766528297D7D29292C702626732E6F6E282263';
wwv_flow_api.g_varchar2_table(28) := '6C69636B222C2866756E6374696F6E28297B642E72656D6F766528297D29292C2266756E6374696F6E223D3D747970656F6620742E6F6E636C69636B262628642E6F6E2822636C69636B222C742E6F6E636C69636B292C702626732E6F6E2822636C6963';
wwv_flow_api.g_varchar2_table(29) := '6B222C742E6F6E636C69636B29292C647D7D72657475726E7B737563636573733A66756E6374696F6E28652C6E2C73297B72657475726E206328742C652C6E2C73297D2C696E666F3A66756E6374696F6E28652C742C73297B72657475726E2063286E2C';
wwv_flow_api.g_varchar2_table(30) := '652C742C73297D2C7761726E696E673A66756E6374696F6E28652C742C6E297B72657475726E206328732C652C742C6E297D2C6572726F723A66756E6374696F6E28652C742C6E297B72657475726E206328692C652C742C6E297D2C636C656172416C6C';
wwv_flow_api.g_varchar2_table(31) := '3A6C2C76657273696F6E3A2232302E322E30227D7D28293B0A2F2F2320736F757263654D617070696E6755524C3D666F7374722E6A732E6D6170';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(729781119183330294)
,p_plugin_id=>wwv_flow_api.id(441585844511348477)
,p_file_name=>'js/fostr.min.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A20676C6F62616C732061706578202A2F0A0A76617220464F53203D2077696E646F772E464F53207C7C207B7D3B0A464F532E696E74657261637469766547726964203D20464F532E696E74657261637469766547726964207C7C207B7D3B0A0A2F2A';
wwv_flow_api.g_varchar2_table(2) := '2A0A202A20546869732066756E6374696F6E2074726967676572732074686520504C2F53514C2070726F63657373696E67206F662073656C65637465642F66696C746572656420726F7773206F6E20746865207365727665722E0A202A0A202A20407061';
wwv_flow_api.g_varchar2_table(3) := '72616D207B6F626A6563747D2020206461436F6E746578742020202020202020202020202020202020202020202044796E616D696320416374696F6E20636F6E746578742061732070617373656420696E20627920415045580A202A2040706172616D20';
wwv_flow_api.g_varchar2_table(4) := '7B6F626A6563747D202020636F6E66696720202020202020202020202020202020202020202020202020436F6E66696775726174696F6E206F626A65637420686F6C64696E67207468652070726F636573732073657474696E67730A202A204070617261';
wwv_flow_api.g_varchar2_table(5) := '6D207B737472696E677D202020636F6E6669672E616A61784964202020202020202020202020202020202020414A4158206964656E7469666965722070726F76696465642062792074686520706C75672D696E20696E746572666163650A202A20407061';
wwv_flow_api.g_varchar2_table(6) := '72616D207B737472696E677D202020636F6E6669672E6D6F6465202020202020202020202020202020202020202050726F63657373696E67206D6F64652E20456974686572202773656C656374696F6E27206F72202766696C7465726564270A202A2040';
wwv_flow_api.g_varchar2_table(7) := '706172616D207B737472696E675B5D7D205B636F6E6669672E6974656D73546F5375626D69745D2020202020202020204172726179206F66206974656D206E616D657320746F207375626D697420746F20746865207365727665720A202A204070617261';
wwv_flow_api.g_varchar2_table(8) := '6D207B626F6F6C65616E7D20205B636F6E6669672E7265667265736853656C656374696F6E5D2020202020205768657468657220746F2072656672657368207468652073656C656374696F6E2061667465722070726F63657373696E670A202A20407061';
wwv_flow_api.g_varchar2_table(9) := '72616D207B626F6F6C65616E7D20205B636F6E6669672E72656672657368477269645D20202020202020202020205768657468657220746F20726566726573682074686520656E7469726520677269642061667465722070726F63657373696E670A202A';
wwv_flow_api.g_varchar2_table(10) := '2040706172616D207B626F6F6C65616E7D20205B636F6E6669672E706572666F726D537562737469747574696F6E735D202057686574686572207468652073756363657373206F72206572726F72206D6573736167652073686F756C6420706572666F72';
wwv_flow_api.g_varchar2_table(11) := '6D206974656D2073757362737469747574696F6E73206265666F7265206265696E672073686F776E0A202A2040706172616D207B626F6F6C65616E7D20205B636F6E6669672E6573636170654D6573736167655D20202020202020202057686574686572';
wwv_flow_api.g_varchar2_table(12) := '20746F20657363617065207468652073756363657373206F72206572726F72206D657373616765206265666F7265206265696E672073686F776E0A202A2040706172616D207B66756E6374696F6E7D205B696E6974466E5D202020202020202020202020';
wwv_flow_api.g_varchar2_table(13) := '20202020202020202020204A61766173637269707420696E697469616C697A6174696F6E2066756E6374696F6E20776869636820616C6C6F777320796F7520746F206F7665727269646520616E792073657474696E6773207269676874206265666F7265';
wwv_flow_api.g_varchar2_table(14) := '207468652064796E616D696320616374696F6E20697320696E766F6B656E0A202A2F0A464F532E696E746572616374697665477269642E70726F63657373526F7773203D2066756E6374696F6E20286461436F6E746578742C20636F6E6669672C20696E';
wwv_flow_api.g_varchar2_table(15) := '6974466E29207B0A202020200A202020202F2F20636F6E7374616E74730A2020202076617220435F44414E474552203D202764616E676572273B0A2020202076617220435F4552524F52203D20276572726F72273B0A2020202076617220435F494E464F';
wwv_flow_api.g_varchar2_table(16) := '203D2027696E666F273B0A2020202076617220435F53554343455353203D202773756363657373273B0A2020202076617220435F5741524E494E47203D20277761726E696E67273B0A0A2020202076617220706C7567696E4E616D65203D2027464F5320';
wwv_flow_api.g_varchar2_table(17) := '2D20496E7465726163746976652047726964202D2050726F6365737320526F7773273B0A202020200A20202020617065782E64656275672E696E666F28706C7567696E4E616D652C20636F6E666967293B0A0A202020202F2F20416C6C6F772074686520';
wwv_flow_api.g_varchar2_table(18) := '646576656C6F70657220746F20706572666F726D20616E79206C617374202863656E7472616C697A656429206368616E676573207573696E67204A61766173637269707420496E697469616C697A6174696F6E20436F64650A2020202069662028696E69';
wwv_flow_api.g_varchar2_table(19) := '74466E20696E7374616E63656F662046756E6374696F6E29207B0A2020202020202020666F737472203D20666F737472207C7C207B7D3B0A2020202020202020696E6974466E2E63616C6C286461436F6E746578742C20636F6E6669672C20666F737472';
wwv_flow_api.g_varchar2_table(20) := '4F7074696F6E73293B0A202020207D0A0A2020202076617220666F7374724F7074696F6E73203D207B7D3B0A20202020666F7374724F7074696F6E73203D207B0A20202020202020206469736D6973733A205B276F6E436C69636B272C20276F6E427574';
wwv_flow_api.g_varchar2_table(21) := '746F6E275D2C0A20202020202020206469736D69737341667465723A20636F6E6669672E6469736D69737341667465722C0A20202020202020206E65776573744F6E546F703A20747275652C0A202020202020202070726576656E744475706C69636174';
wwv_flow_api.g_varchar2_table(22) := '65733A2066616C73652C0A202020202020202065736361706548746D6C3A2066616C73652C0A2020202020202020706F736974696F6E3A2027746F702D7269676874272C0A202020202020202069636F6E436C6173733A206E756C6C2C0A202020202020';
wwv_flow_api.g_varchar2_table(23) := '2020636C656172416C6C3A2066616C73650A202020207D3B0A0A2020202076617220726567696F6E4964203D206461436F6E746578742E616374696F6E2E6166666563746564526567696F6E49643B0A2020202076617220616A61784964203D20636F6E';
wwv_flow_api.g_varchar2_table(24) := '6669672E616A617849643B0A0A2020202076617220726567696F6E203D20617065782E726567696F6E28726567696F6E4964293B0A0A202020202F2F207761726E20616E642061626F72742069662074686520616666656374656420656C656D656E7420';
wwv_flow_api.g_varchar2_table(25) := '6973206E6F7420616E20496E746572616374697665204772696420726567696F6E0A202020206966202821726567696F6E207C7C20726567696F6E2E7479706520213D2027496E746572616374697665477269642729207B0A2020202020202020746872';
wwv_flow_api.g_varchar2_table(26) := '6F77206E6577204572726F72282754686520616666656374656420656C656D656E74206F6620706C75672D696E202227202B20706C7567696E4E616D65202B202722206D75737420626520616E20496E746572616374697665204772696420726567696F';
wwv_flow_api.g_varchar2_table(27) := '6E2E27293B0A202020207D0A0A20202020766172206630313B0A20202020766172206F726967696E616C53656C656374696F6E3B0A0A202020202F2F20696E2073656C656374696F6E206D6F64652C2074616B6520616C6C207468652073656C65637469';
wwv_flow_api.g_varchar2_table(28) := '6F6E206173206A736F6E2C20737472696E676966792069742C20616E64206368756E6B20697420696E746F206630310A2020202069662028636F6E6669672E6D6F6465203D3D202773656C656374696F6E2729207B0A2020202020202020766172207365';
wwv_flow_api.g_varchar2_table(29) := '6C65637465645265636F726473203D20726567696F6E2E63616C6C282767657453656C65637465645265636F72647327293B0A0A20202020202020202F2F206B65657020747261636B206F662073656C656374696F6E20746F2072656672657368206C61';
wwv_flow_api.g_varchar2_table(30) := '7465720A202020202020202069662028636F6E6669672E7265667265736853656C656374696F6E29207B0A2020202020202020202020206F726967696E616C53656C656374696F6E203D2073656C65637465645265636F7264733B0A2020202020202020';
wwv_flow_api.g_varchar2_table(31) := '7D0A0A20202020202020202F2F206966206E6F20726F7773206172652073656C65637465642C2074686572652773206E6F206E65656420746F20636F6E7461637420746865207365727665720A20202020202020206966202873656C6563746564526563';
wwv_flow_api.g_varchar2_table(32) := '6F7264732E6C656E677468203D3D203029207B0A202020202020202020202020617065782E64656275672E696E666F28274E6F2073656C6563746564207265636F7264732E20436F6E74696E75696E6720776974686F7574207365727665722063616C6C';
wwv_flow_api.g_varchar2_table(33) := '2E27293B0A2020202020202020202020202F2A0A20202020202020202020202069662028617065782E6C616E672E6861734D6573736167652827415045582E47562E53454C454354494F4E5F434F554E54272929207B0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(34) := '202020242E657874656E6428666F7374724F7074696F6E732C207B0A20202020202020202020202020202020202020206D6573736167653A20617065782E6C616E672E666F726D61744D6573736167652827415045582E47562E53454C454354494F4E5F';
wwv_flow_api.g_varchar2_table(35) := '434F554E54272C2030292C0A20202020202020202020202020202020202020207469746C653A20756E646566696E65642C0A2020202020202020202020202020202020202020747970653A20435F5741524E494E470A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(36) := '20207D293B0A20202020202020202020202020202020666F7374725B435F5741524E494E475D28666F7374724F7074696F6E73293B0A2020202020202020202020207D0A2020202020202020202020202A2F0A2020202020202020202020207661722065';
wwv_flow_api.g_varchar2_table(37) := '72726F724F63637572726564203D2066616C73653B0A202020202020202020202020617065782E64612E726573756D65286461436F6E746578742E726573756D6543616C6C6261636B2C206572726F724F63637572726564293B0A202020202020202020';
wwv_flow_api.g_varchar2_table(38) := '20202072657475726E3B0A20202020202020207D0A0A20202020202020202F2F2067657420616E206172726179206F6620616C6C2073656C6563746564207072696D617279206B6579732C20616E642073656E642069742061732061207374696E676966';
wwv_flow_api.g_varchar2_table(39) := '696564206A736F6E20766961206630310A2020202020202020766172206D6F64656C203D20726567696F6E2E63616C6C28276765745669657773272C20276772696427292E6D6F64656C3B0A20202020202020207661722073656C656374696F6E203D20';
wwv_flow_api.g_varchar2_table(40) := '7B0A2020202020202020202020207265636F72644B6579733A2073656C65637465645265636F7264732E6D61702866756E6374696F6E20287265636F726429207B0A2020202020202020202020202020202072657475726E206D6F64656C2E5F67657450';
wwv_flow_api.g_varchar2_table(41) := '72696D6172794B6579287265636F7264293B0A2020202020202020202020207D290A20202020202020207D3B0A0A2020202020202020663031203D20617065782E7365727665722E6368756E6B284A534F4E2E737472696E676966792873656C65637469';
wwv_flow_api.g_varchar2_table(42) := '6F6E29293B0A202020207D0A0A2020202076617220726573756C74203D20617065782E7365727665722E706C7567696E28616A617849642C207B0A20202020202020206630313A206630312C0A2020202020202020706167654974656D733A20636F6E66';
wwv_flow_api.g_varchar2_table(43) := '69672E6974656D73546F5375626D69740A202020207D293B0A0A20202020726573756C742E646F6E652866756E6374696F6E20286461746129207B0A20202020202020207661722063616E63656C416374696F6E73203D2066616C73653B0A0A20202020';
wwv_flow_api.g_varchar2_table(44) := '20202020766172206D657373616765203D20646174612E6D6573736167653B0A2020202020202020766172206D6573736167655469746C65203D20646174612E6D6573736167655469746C653B0A2020202020202020766172206D657373616765547970';
wwv_flow_api.g_varchar2_table(45) := '65203D2028646174612E6D65737361676554797065202626205B435F494E464F2C20435F5741524E494E472C20435F535543434553532C20435F4552524F522C20435F44414E4745525D2E696E636C7564657328646174612E6D65737361676554797065';
wwv_flow_api.g_varchar2_table(46) := '2929203F20646174612E6D65737361676554797065203A202773756363657373273B0A20202020202020206D65737361676554797065203D20286D65737361676554797065203D3D3D20435F44414E47455229203F20435F4552524F52203A206D657373';
wwv_flow_api.g_varchar2_table(47) := '616765547970653B0A0A20202020202020202F2F20636865636B2069662074686520646576656C6F7065722077616E747320746F2063616E63656C20666F6C6C6F77696E6720616374696F6E730A202020202020202063616E63656C416374696F6E7320';
wwv_flow_api.g_varchar2_table(48) := '3D202121646174612E63616E63656C416374696F6E733B202F2F20656E737572652077652068617665206120626F6F6C65616E20726573706F6E73652069662061747472696275746520697320756E646566696E65640A0A20202020202020202F2F2070';
wwv_flow_api.g_varchar2_table(49) := '6572666F726D696E6720636C69656E742D73696465206974656D2073757362737469747574696F6E730A2020202020202020696620286D6573736167655469746C6520262620636F6E6669672E706572666F726D537562737469747574696F6E7329207B';
wwv_flow_api.g_varchar2_table(50) := '0A2020202020202020202020206D6573736167655469746C65203D20617065782E7574696C2E6170706C7954656D706C617465286D6573736167655469746C652C207B0A2020202020202020202020202020202064656661756C7445736361706546696C';
wwv_flow_api.g_varchar2_table(51) := '7465723A206E756C6C0A2020202020202020202020207D293B0A20202020202020207D0A2020202020202020696620286D65737361676520262620636F6E6669672E706572666F726D537562737469747574696F6E7329207B0A20202020202020202020';
wwv_flow_api.g_varchar2_table(52) := '20206D657373616765203D20617065782E7574696C2E6170706C7954656D706C617465286D6573736167652C207B0A2020202020202020202020202020202064656661756C7445736361706546696C7465723A206E756C6C0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(53) := '207D293B0A20202020202020207D0A0A20202020202020202F2F20706572666F726D696E67206573636170696E670A2020202020202020696620286D6573736167655469746C6520262620636F6E6669672E6573636170654D65737361676529207B0A20';
wwv_flow_api.g_varchar2_table(54) := '20202020202020202020206D6573736167655469746C65203D20617065782E7574696C2E65736361706548544D4C286D6573736167655469746C65293B0A20202020202020207D0A2020202020202020696620286D65737361676520262620636F6E6669';
wwv_flow_api.g_varchar2_table(55) := '672E6573636170654D65737361676529207B0A2020202020202020202020206D657373616765203D20617065782E7574696C2E65736361706548544D4C286D657373616765293B0A20202020202020207D0A0A202020202020202069662028646174612E';
wwv_flow_api.g_varchar2_table(56) := '737461747573203D3D20435F5355434345535329207B0A0A2020202020202020202020202F2F2073657420616E79206974656D7320746F2072657475726E0A20202020202020202020202069662028646174612E6974656D73546F52657475726E29207B';
wwv_flow_api.g_varchar2_table(57) := '0A20202020202020202020202020202020666F7220287661722069203D20303B2069203C20646174612E6974656D73546F52657475726E2E6C656E6774683B20692B2B29207B0A2020202020202020202020202020202020202020617065782E6974656D';
wwv_flow_api.g_varchar2_table(58) := '28646174612E6974656D73546F52657475726E5B695D2E6E616D65292E73657456616C756528646174612E6974656D73546F52657475726E5B695D2E76616C7565293B0A202020202020202020202020202020207D0A2020202020202020202020207D0A';
wwv_flow_api.g_varchar2_table(59) := '0A2020202020202020202020202F2F20726566726573682073656C656374656420726F7773206966206F7074696F6E206973207365740A20202020202020202020202069662028636F6E6669672E7265667265736853656C656374696F6E29207B0A2020';
wwv_flow_api.g_varchar2_table(60) := '2020202020202020202020202020726567696F6E2E63616C6C28276765745669657773272C20276772696427292E6D6F64656C2E66657463685265636F726473286F726967696E616C53656C656374696F6E293B0A2020202020202020202020207D0A0A';
wwv_flow_api.g_varchar2_table(61) := '2020202020202020202020202F2F207265667265736820656E746972652067726964206966206F7074696F6E206973207365740A20202020202020202020202069662028636F6E6669672E726566726573684772696429207B0A20202020202020202020';
wwv_flow_api.g_varchar2_table(62) := '202020202020726567696F6E2E7265667265736828293B0A0A202020202020202020202020202020202F2F2069662072656D6F76652073656C656374696F6E20697320656E61626C65642C207765206D757374207761697420756E74696C207468652067';
wwv_flow_api.g_varchar2_table(63) := '726964206973206C6F616465640A202020202020202020202020202020202F2F20616E642072656D6F7665207468652073656C656374696F6E20616674657220746861740A20202020202020202020202020202020696628636F6E6669672E72656D6F76';
wwv_flow_api.g_varchar2_table(64) := '6553656C656374696F6E297B0A202020202020202020202020202020202020202024282723272B726567696F6E4964292E6F6E652827696E7465726163746976656772696473656C656374696F6E6368616E6765272C202865293D3E7B0A202020202020';
wwv_flow_api.g_varchar2_table(65) := '202020202020202020202020202020202020726567696F6E2E63616C6C282773657453656C65637465645265636F726473272C202727293B0A20202020202020202020202020202020202020207D290A202020202020202020202020202020207D0A2020';
wwv_flow_api.g_varchar2_table(66) := '202020202020202020207D0A0A2020202020202020202020202F2F2072656D6F76652073656C656374696F6E0A202020202020202020202020696628636F6E6669672E72656D6F766553656C656374696F6E2026262021636F6E6669672E726566726573';
wwv_flow_api.g_varchar2_table(67) := '6847726964297B0A20202020202020202020202020202020726567696F6E2E63616C6C282773657453656C65637465645265636F726473272C202727293B0A2020202020202020202020207D0A0A2020202020202020202020202F2F2073686F77206E6F';
wwv_flow_api.g_varchar2_table(68) := '74696669636174696F6E206D6573736167650A202020202020202020202020696620286D65737361676529207B0A20202020202020202020202020202020242E657874656E6428666F7374724F7074696F6E732C207B0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(69) := '202020202020206D6573736167653A206D6573736167652C0A20202020202020202020202020202020202020207469746C653A206D6573736167655469746C652C0A2020202020202020202020202020202020202020747970653A206D65737361676554';
wwv_flow_api.g_varchar2_table(70) := '7970650A202020202020202020202020202020207D293B0A20202020202020202020202020202020666F7374725B6D657373616765547970655D28666F7374724F7074696F6E73293B0A2020202020202020202020207D0A0A20202020202020207D2065';
wwv_flow_api.g_varchar2_table(71) := '6C7365207B0A20202020202020202020202063616E63656C416374696F6E73203D20747275653B0A0A202020202020202020202020696620286D65737361676529207B0A20202020202020202020202020202020242E657874656E6428666F7374724F70';
wwv_flow_api.g_varchar2_table(72) := '74696F6E732C207B0A20202020202020202020202020202020202020206D6573736167653A206D6573736167652C0A20202020202020202020202020202020202020207469746C653A206D6573736167655469746C652C0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(73) := '2020202020202020747970653A20435F4552524F520A202020202020202020202020202020207D293B0A20202020202020202020202020202020666F7374722E6572726F7228666F7374724F7074696F6E73293B0A2020202020202020202020207D0A20';
wwv_flow_api.g_varchar2_table(74) := '202020202020207D0A0A20202020202020202F2F204F7074696F6E616C6C79206669726520616E206576656E742069662074686520646576656C6F70657220646569666E6564206F6E65207573696E6720617065785F6170706C69636174696F6E2E675F';
wwv_flow_api.g_varchar2_table(75) := '7830350A202020202020202069662028646174612E6576656E744E616D6529207B0A202020202020202020202020617065782E6576656E742E747269676765722827626F6479272C20646174612E6576656E744E616D652C2064617461293B0A20202020';
wwv_flow_api.g_varchar2_table(76) := '202020207D0A0A2020202020202020617065782E64612E726573756D65286461436F6E746578742E726573756D6543616C6C6261636B2C2063616E63656C416374696F6E73293B0A0A202020207D292E6661696C2866756E6374696F6E20286A71584852';
wwv_flow_api.g_varchar2_table(77) := '2C20746578745374617475732C206572726F725468726F776E29207B0A2020202020202020617065782E64612E68616E646C65416A61784572726F7273286A715848522C20746578745374617475732C206572726F725468726F776E2C206461436F6E74';
wwv_flow_api.g_varchar2_table(78) := '6578742E726573756D6543616C6C6261636B293B0A202020207D293B0A7D3B0A0A0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(729781465410330294)
,p_plugin_id=>wwv_flow_api.id(441585844511348477)
,p_file_name=>'js/script.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '7B2276657273696F6E223A332C22736F7572636573223A5B227363726970742E6A73225D2C226E616D6573223A5B22464F53222C2277696E646F77222C22696E74657261637469766547726964222C2270726F63657373526F7773222C226461436F6E74';
wwv_flow_api.g_varchar2_table(2) := '657874222C22636F6E666967222C22696E6974466E222C22435F44414E474552222C22435F4552524F52222C22435F494E464F222C22435F53554343455353222C22435F5741524E494E47222C22706C7567696E4E616D65222C2261706578222C226465';
wwv_flow_api.g_varchar2_table(3) := '627567222C22696E666F222C2246756E6374696F6E222C22666F737472222C2263616C6C222C22666F7374724F7074696F6E73222C226469736D697373222C226469736D6973734166746572222C226E65776573744F6E546F70222C2270726576656E74';
wwv_flow_api.g_varchar2_table(4) := '4475706C696361746573222C2265736361706548746D6C222C22706F736974696F6E222C2269636F6E436C617373222C22636C656172416C6C222C22663031222C226F726967696E616C53656C656374696F6E222C22726567696F6E4964222C22616374';
wwv_flow_api.g_varchar2_table(5) := '696F6E222C226166666563746564526567696F6E4964222C22616A61784964222C22726567696F6E222C2274797065222C224572726F72222C226D6F6465222C2273656C65637465645265636F726473222C227265667265736853656C656374696F6E22';
wwv_flow_api.g_varchar2_table(6) := '2C226C656E677468222C226461222C22726573756D65222C22726573756D6543616C6C6261636B222C226D6F64656C222C2273656C656374696F6E222C227265636F72644B657973222C226D6170222C227265636F7264222C225F6765745072696D6172';
wwv_flow_api.g_varchar2_table(7) := '794B6579222C22736572766572222C226368756E6B222C224A534F4E222C22737472696E67696679222C22706C7567696E222C22706167654974656D73222C226974656D73546F5375626D6974222C22646F6E65222C2264617461222C2263616E63656C';
wwv_flow_api.g_varchar2_table(8) := '416374696F6E73222C226D657373616765222C226D6573736167655469746C65222C226D65737361676554797065222C22696E636C75646573222C22706572666F726D537562737469747574696F6E73222C227574696C222C226170706C7954656D706C';
wwv_flow_api.g_varchar2_table(9) := '617465222C2264656661756C7445736361706546696C746572222C226573636170654D657373616765222C2265736361706548544D4C222C22737461747573222C226974656D73546F52657475726E222C2269222C226974656D222C226E616D65222C22';
wwv_flow_api.g_varchar2_table(10) := '73657456616C7565222C2276616C7565222C2266657463685265636F726473222C227265667265736847726964222C2272656672657368222C2272656D6F766553656C656374696F6E222C2224222C226F6E65222C2265222C22657874656E64222C2274';
wwv_flow_api.g_varchar2_table(11) := '69746C65222C226572726F72222C226576656E744E616D65222C226576656E74222C2274726967676572222C226661696C222C226A71584852222C2274657874537461747573222C226572726F725468726F776E222C2268616E646C65416A6178457272';
wwv_flow_api.g_varchar2_table(12) := '6F7273225D2C226D617070696E6773223A22414145412C49414149412C4941414D432C4F41414F442C4B41414F2C4741437842412C49414149452C674241416B42462C49414149452C694241416D422C474167423743462C49414149452C674241416742';
wwv_flow_api.g_varchar2_table(13) := '432C594141632C53414155432C45414157432C45414151432C47414733442C49414149432C454141572C53414358432C454141552C51414356432C454141532C4F414354432C454141592C5541435A432C454141592C5541455A432C454141612C774341';
wwv_flow_api.g_varchar2_table(14) := '456A42432C4B41414B432C4D41414D432C4B41414B482C45414159502C4741477842432C6141416B42552C5741436C42432C4D414151412C4F4141532C4741436A42582C4541414F592C4B41414B642C45414157432C45414151632C4941476E432C4941';
wwv_flow_api.g_varchar2_table(15) := '4149412C454141652C4741436E42412C454141652C43414358432C514141532C434141432C554141572C5941437242432C6141416368422C4541414F67422C6141437242432C614141612C45414362432C6D4241416D422C4541436E42432C594141592C';
wwv_flow_api.g_varchar2_table(16) := '4541435A432C534141552C59414356432C554141572C4B414358432C554141552C474147642C49415549432C45414341432C45415841432C4541415731422C4541415532422C4F41414F432C694241433542432C4541415335422C4541414F34422C4F41';
wwv_flow_api.g_varchar2_table(17) := '456842432C4541415372422C4B41414B71422C4F41414F4A2C4741477A422C4941414B492C47414179422C6D42414166412C4541414F432C4B41436C422C4D41414D2C49414149432C4D41414D2C6F434141734378422C454141612C7943414F76452C47';
wwv_flow_api.g_varchar2_table(18) := '41416D422C61414166502C4541414F67432C4B414171422C43414335422C49414149432C4541416B424A2C4541414F68422C4B41414B2C734241516C432C47414C49622C4541414F6B432C6D42414350562C4541416F42532C4741494D2C474141314241';
wwv_flow_api.g_varchar2_table(19) := '2C4541416742452C4F4141612C434143374233422C4B41414B432C4D41414D432C4B41414B2C7744416168422C59414441462C4B41414B34422C47414147432C4F41414F74432C4541415575432C674241444C2C47414D78422C49414149432C45414151';
wwv_flow_api.g_varchar2_table(20) := '562C4541414F68422C4B41414B2C574141592C5141415130422C4D41437843432C454141592C4341435A432C57414159522C4541416742532C4B4141492C53414155432C47414374432C4F41414F4A2C4541414D4B2C65414165442C4F4149704370422C';
wwv_flow_api.g_varchar2_table(21) := '4541414D662C4B41414B71432C4F41414F432C4D41414D432C4B41414B432C55414155522C494147394268432C4B41414B71432C4F41414F492C4F41414F72422C454141512C43414370434C2C4941414B412C4541434C32422C554141576C442C454141';
wwv_flow_api.g_varchar2_table(22) := '4F6D442C6742414766432C4D41414B2C53414155432C4741436C422C49414149432C47414167422C4541456842432C45414155462C4541414B452C51414366432C45414165482C4541414B472C6141437042432C454141654A2C4541414B492C61414165';
wwv_flow_api.g_varchar2_table(23) := '2C4341414372442C45414151452C45414157442C45414157462C45414153442C4741415577442C534141534C2C4541414B492C61414167424A2C4541414B492C594141632C5541304231492C47417A4241412C45414165412C494141674276442C454141';
wwv_flow_api.g_varchar2_table(24) := '59432C4541415573442C4541477244482C4941416B42442C4541414B432C6341476E42452C474141674278442C4541414F32442C754241437642482C4541416568442C4B41414B6F442C4B41414B432C634141634C2C454141632C4341436A444D2C6F42';
wwv_flow_api.g_varchar2_table(25) := '414171422C5141477A42502C4741415776442C4541414F32442C754241436C424A2C454141552F432C4B41414B6F442C4B41414B432C634141634E2C454141532C43414376434F2C6F42414171422C51414B7A424E2C474141674278442C4541414F2B44';
wwv_flow_api.g_varchar2_table(26) := '2C674241437642502C4541416568442C4B41414B6F442C4B41414B492C57414157522C4941457043442C4741415776442C4541414F2B442C674241436C42522C454141552F432C4B41414B6F442C4B41414B492C57414157542C4941472F42462C454141';
wwv_flow_api.g_varchar2_table(27) := '4B592C5141415535442C454141572C43414731422C4741414967442C4541414B612C6341434C2C4941414B2C49414149432C454141492C45414147412C45414149642C4541414B612C634141632F422C4F41415167432C494143334333442C4B41414B34';
wwv_flow_api.g_varchar2_table(28) := '442C4B41414B662C4541414B612C63414163432C47414147452C4D41414D432C534141536A422C4541414B612C63414163432C47414147492C4F414B7A4576452C4541414F6B432C6B424143504C2C4541414F68422C4B41414B2C574141592C51414151';
wwv_flow_api.g_varchar2_table(29) := '30422C4D41414D69432C6141416168442C4741496E4478422C4541414F79452C6341435035432C4541414F36432C5541494A31452C4541414F32452C694241434E432C454141452C494141496E442C474141556F442C494141492C6B4341416D43432C49';
wwv_flow_api.g_varchar2_table(30) := '41436E446A442C4541414F68422C4B41414B2C7142414173422C51414D3343622C4541414F32452C6B4241416F4233452C4541414F79452C6141436A4335432C4541414F68422C4B41414B2C7142414173422C4941496C4330432C4941434171422C4541';
wwv_flow_api.g_varchar2_table(31) := '4145472C4F41414F6A452C454141632C4341436E4279432C51414153412C4541435479422C4D41414F78422C4541435031422C4B41414D32422C4941455637432C4D41414D36432C4741416133432C534149764277432C47414167422C4541455A432C49';
wwv_flow_api.g_varchar2_table(32) := '41434171422C45414145472C4F41414F6A452C454141632C4341436E4279432C51414153412C4541435479422C4D41414F78422C4541435031422C4B41414D33422C49414556532C4D41414D71452C4D41414D6E452C49414B684275432C4541414B3642';
wwv_flow_api.g_varchar2_table(33) := '2C5741434C31452C4B41414B32452C4D41414D432C514141512C4F4141512F422C4541414B36422C5541415737422C4741472F4337432C4B41414B34422C47414147432C4F41414F74432C4541415575432C654141674267422C4D414531432B422C4D41';
wwv_flow_api.g_varchar2_table(34) := '414B2C53414155432C4541414F432C45414159432C4741436A4368462C4B41414B34422C4741414771442C694241416942482C4541414F432C45414159432C454141617A462C454141557543222C2266696C65223A227363726970742E6A73227D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(729781827483330294)
,p_plugin_id=>wwv_flow_api.id(441585844511348477)
,p_file_name=>'js/script.js.map'
,p_mime_type=>'application/json'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '76617220464F533D77696E646F772E464F537C7C7B7D3B464F532E696E746572616374697665477269643D464F532E696E746572616374697665477269647C7C7B7D2C464F532E696E746572616374697665477269642E70726F63657373526F77733D66';
wwv_flow_api.g_varchar2_table(2) := '756E6374696F6E28652C742C72297B76617220733D2264616E676572222C693D226572726F72222C613D22696E666F222C6E3D2273756363657373222C6C3D227761726E696E67222C6F3D22464F53202D20496E7465726163746976652047726964202D';
wwv_flow_api.g_varchar2_table(3) := '2050726F6365737320526F7773223B617065782E64656275672E696E666F286F2C74292C7220696E7374616E63656F662046756E6374696F6E262628666F7374723D666F7374727C7C7B7D2C722E63616C6C28652C742C6329293B76617220633D7B7D3B';
wwv_flow_api.g_varchar2_table(4) := '633D7B6469736D6973733A5B226F6E436C69636B222C226F6E427574746F6E225D2C6469736D69737341667465723A742E6469736D69737341667465722C6E65776573744F6E546F703A21302C70726576656E744475706C6963617465733A21312C6573';
wwv_flow_api.g_varchar2_table(5) := '6361706548746D6C3A21312C706F736974696F6E3A22746F702D7269676874222C69636F6E436C6173733A6E756C6C2C636C656172416C6C3A21317D3B76617220642C752C703D652E616374696F6E2E6166666563746564526567696F6E49642C6D3D74';
wwv_flow_api.g_varchar2_table(6) := '2E616A617849642C663D617065782E726567696F6E2870293B69662821667C7C22496E7465726163746976654772696422213D662E74797065297468726F77206E6577204572726F72282754686520616666656374656420656C656D656E74206F662070';
wwv_flow_api.g_varchar2_table(7) := '6C75672D696E2022272B6F2B2722206D75737420626520616E20496E746572616374697665204772696420726567696F6E2E27293B6966282273656C656374696F6E223D3D742E6D6F6465297B76617220673D662E63616C6C282267657453656C656374';
wwv_flow_api.g_varchar2_table(8) := '65645265636F72647322293B696628742E7265667265736853656C656374696F6E262628753D67292C303D3D672E6C656E677468297B617065782E64656275672E696E666F28224E6F2073656C6563746564207265636F7264732E20436F6E74696E7569';
wwv_flow_api.g_varchar2_table(9) := '6E6720776974686F7574207365727665722063616C6C2E22293B72657475726E20766F696420617065782E64612E726573756D6528652E726573756D6543616C6C6261636B2C2131297D76617220763D662E63616C6C28226765745669657773222C2267';
wwv_flow_api.g_varchar2_table(10) := '72696422292E6D6F64656C2C783D7B7265636F72644B6579733A672E6D6170282866756E6374696F6E2865297B72657475726E20762E5F6765745072696D6172794B65792865297D29297D3B643D617065782E7365727665722E6368756E6B284A534F4E';
wwv_flow_api.g_varchar2_table(11) := '2E737472696E67696679287829297D617065782E7365727665722E706C7567696E286D2C7B6630313A642C706167654974656D733A742E6974656D73546F5375626D69747D292E646F6E65282866756E6374696F6E2872297B766172206F3D21312C643D';
wwv_flow_api.g_varchar2_table(12) := '722E6D6573736167652C6D3D722E6D6573736167655469746C652C673D722E6D6573736167655479706526265B612C6C2C6E2C692C735D2E696E636C7564657328722E6D65737361676554797065293F722E6D657373616765547970653A227375636365';
wwv_flow_api.g_varchar2_table(13) := '7373223B696628673D673D3D3D733F693A672C6F3D2121722E63616E63656C416374696F6E732C6D2626742E706572666F726D537562737469747574696F6E732626286D3D617065782E7574696C2E6170706C7954656D706C617465286D2C7B64656661';
wwv_flow_api.g_varchar2_table(14) := '756C7445736361706546696C7465723A6E756C6C7D29292C642626742E706572666F726D537562737469747574696F6E73262628643D617065782E7574696C2E6170706C7954656D706C61746528642C7B64656661756C7445736361706546696C746572';
wwv_flow_api.g_varchar2_table(15) := '3A6E756C6C7D29292C6D2626742E6573636170654D6573736167652626286D3D617065782E7574696C2E65736361706548544D4C286D29292C642626742E6573636170654D657373616765262628643D617065782E7574696C2E65736361706548544D4C';
wwv_flow_api.g_varchar2_table(16) := '286429292C722E7374617475733D3D6E297B696628722E6974656D73546F52657475726E29666F722876617220763D303B763C722E6974656D73546F52657475726E2E6C656E6774683B762B2B29617065782E6974656D28722E6974656D73546F526574';
wwv_flow_api.g_varchar2_table(17) := '75726E5B765D2E6E616D65292E73657456616C756528722E6974656D73546F52657475726E5B765D2E76616C7565293B742E7265667265736853656C656374696F6E2626662E63616C6C28226765745669657773222C226772696422292E6D6F64656C2E';
wwv_flow_api.g_varchar2_table(18) := '66657463685265636F7264732875292C742E7265667265736847726964262628662E7265667265736828292C742E72656D6F766553656C656374696F6E262624282223222B70292E6F6E652822696E7465726163746976656772696473656C656374696F';
wwv_flow_api.g_varchar2_table(19) := '6E6368616E6765222C28653D3E7B662E63616C6C282273657453656C65637465645265636F726473222C2222297D2929292C742E72656D6F766553656C656374696F6E262621742E72656672657368477269642626662E63616C6C282273657453656C65';
wwv_flow_api.g_varchar2_table(20) := '637465645265636F726473222C2222292C64262628242E657874656E6428632C7B6D6573736167653A642C7469746C653A6D2C747970653A677D292C666F7374725B675D286329297D656C7365206F3D21302C64262628242E657874656E6428632C7B6D';
wwv_flow_api.g_varchar2_table(21) := '6573736167653A642C7469746C653A6D2C747970653A697D292C666F7374722E6572726F72286329293B722E6576656E744E616D652626617065782E6576656E742E747269676765722822626F6479222C722E6576656E744E616D652C72292C61706578';
wwv_flow_api.g_varchar2_table(22) := '2E64612E726573756D6528652E726573756D6543616C6C6261636B2C6F297D29292E6661696C282866756E6374696F6E28742C722C73297B617065782E64612E68616E646C65416A61784572726F727328742C722C732C652E726573756D6543616C6C62';
wwv_flow_api.g_varchar2_table(23) := '61636B297D29297D3B0A2F2F2320736F757263654D617070696E6755524C3D7363726970742E6A732E6D6170';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(729782250257330295)
,p_plugin_id=>wwv_flow_api.id(441585844511348477)
,p_file_name=>'js/script.min.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
prompt --application/end_environment
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done
