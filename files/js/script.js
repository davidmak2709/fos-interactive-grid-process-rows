/* globals apex */

var FOS = window.FOS || {};
FOS.interactiveGrid = FOS.interactiveGrid || {};

/**
 * This function triggers the PL/SQL processing of selected/filtered rows on the server.
 *
 * @param {object}   daContext                      Dynamic Action context as passed in by APEX
 * @param {object}   config                         Configuration object holding the process settings
 * @param {string}   config.ajaxId                  AJAX identifier provided by the plug-in interface
 * @param {string}   config.mode                    Processing mode. Either 'selection' or 'filtered'
 * @param {string[]} [config.itemsToSubmit]         Array of item names to submit to the server
 * @param {boolean}  [config.refreshSelection]      Whether to refresh the selection after processing
 * @param {boolean}  [config.refreshGrid]           Whether to refresh the entire grid after processing
 * @param {boolean}  [config.performSubstitutions]  Whether the success or error message should perform item susbstitutions before being shown
 * @param {boolean}  [config.escapeMessage]         Whether to escape the success or error message before being shown
 * @param {function} [initFn]                       Javascript initialization function which allows you to override any settings right before the dynamic action is invoken
 */
FOS.interactiveGrid.processRows = function (daContext, config, initFn) {
    
    // constants
    var C_DANGER = 'danger';
    var C_ERROR = 'error';
    var C_INFO = 'info';
    var C_SUCCESS = 'success';
    var C_WARNING = 'warning';

    var pluginName = 'FOS - Interactive Grid - Process Rows';
    
    apex.debug.info(pluginName, config);

    // Allow the developer to perform any last (centralized) changes using Javascript Initialization Code
    if (initFn instanceof Function) {
        fostr = fostr || {};
        initFn.call(daContext, config, fostrOptions);
    }

    var fostrOptions = {};
    fostrOptions = {
        dismiss: ['onClick', 'onButton'],
        dismissAfter: config.dismissAfter,
        newestOnTop: true,
        preventDuplicates: false,
        escapeHtml: false,
        position: 'top-right',
        iconClass: null,
        clearAll: false
    };

    var regionId = daContext.action.affectedRegionId;
    var ajaxId = config.ajaxId;

    var region = apex.region(regionId);

    // warn and abort if the affected element is not an Interactive Grid region
    if (!region || region.type != 'InteractiveGrid') {
        throw new Error('The affected element of plug-in "' + pluginName + '" must be an Interactive Grid region.');
    }

    var f01;
    var originalSelection;

    // in selection mode, take all the selection as json, stringify it, and chunk it into f01
    if (config.mode == 'selection') {
        var selectedRecords = region.call('getSelectedRecords');

        // keep track of selection to refresh later
        if (config.refreshSelection) {
            originalSelection = selectedRecords;
        }

        // if no rows are selected, there's no need to contact the server
        if (selectedRecords.length == 0) {
            apex.debug.info('No selected records. Continuing without server call.');
            
            if (apex.lang.hasMessage('APEX.GV.SELECTION_COUNT')) {
                $.extend(fostrOptions, {
                    message: apex.lang.formatMessage('APEX.GV.SELECTION_COUNT', 0),
                    title: undefined,
                    type: C_WARNING
                });
                fostr[C_WARNING](fostrOptions);
            }
            
            var errorOccurred = false;
            apex.da.resume(daContext.resumeCallback, errorOccurred);
            return;
        }

        // get an array of all selected primary keys, and send it as a stingified json via f01
        var model = region.call('getViews', 'grid').model;
        var selection = {
            recordKeys: selectedRecords.map(function (record) {
                return model._getPrimaryKey(record);
            })
        };

        f01 = apex.server.chunk(JSON.stringify(selection));
    }

    var result = apex.server.plugin(ajaxId, {
        f01: f01,
        pageItems: config.itemsToSubmit
    });

    result.done(function (data) {
        var cancelActions = false;

        var message = data.message;
        var messageTitle = data.messageTitle;
        var messageType = (data.messageType && [C_INFO, C_WARNING, C_SUCCESS, C_ERROR, C_DANGER].includes(data.messageType)) ? data.messageType : 'success';
        messageType = (messageType === C_DANGER) ? C_ERROR : messageType;

        // check if the developer wants to cancel following actions
        cancelActions = !!data.cancelActions; // ensure we have a boolean response if attribute is undefined

        // performing client-side item susbstitutions
        if (messageTitle && config.performSubstitutions) {
            messageTitle = apex.util.applyTemplate(messageTitle, {
                defaultEscapeFilter: null
            });
        }
        if (message && config.performSubstitutions) {
            message = apex.util.applyTemplate(message, {
                defaultEscapeFilter: null
            });
        }

        // performing escaping
        if (messageTitle && config.escapeMessage) {
            messageTitle = apex.util.escapeHTML(messageTitle);
        }
        if (message && config.escapeMessage) {
            message = apex.util.escapeHTML(message);
        }

        if (data.status == C_SUCCESS) {

            // set any items to return
            if (data.itemsToReturn) {
                for (var i = 0; i < data.itemsToReturn.length; i++) {
                    apex.item(data.itemsToReturn[i].name).setValue(data.itemsToReturn[i].value);
                }
            }

            // refresh selected rows if option is set
            if (config.refreshSelection) {
                region.call('getViews', 'grid').model.fetchRecords(originalSelection);
            }

            // refresh entire grid if option is set
            if (config.refreshGrid) {
                region.refresh();

                // if remove selection is enabled, we must wait until the grid is loaded
                // and remove the selection after that
                if(config.removeSelection){
                    $('#'+regionId).one('interactivegridselectionchange', (e)=>{
                        region.call('setSelectedRecords', '');
                    })
                }
            }

            // remove selection
            if(config.removeSelection && !config.refreshGrid){
                region.call('setSelectedRecords', '');
            }

            // show notification message
            if (message) {
                $.extend(fostrOptions, {
                    message: message,
                    title: messageTitle,
                    type: messageType
                });
                fostr[messageType](fostrOptions);
            }

        } else {
            cancelActions = true;

            if (message) {
                $.extend(fostrOptions, {
                    message: message,
                    title: messageTitle,
                    type: C_ERROR
                });
                fostr.error(fostrOptions);
            }
        }

        // Optionally fire an event if the developer deifned one using apex_application.g_x05
        if (data.eventName) {
            apex.event.trigger('body', data.eventName, data);
        }

        apex.da.resume(daContext.resumeCallback, cancelActions);

    }).fail(function (jqXHR, textStatus, errorThrown) {
        apex.da.handleAjaxErrors(jqXHR, textStatus, errorThrown, daContext.resumeCallback);
    });
};


