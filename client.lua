local USER_DOCUMENTS = {}
local CURRENT_DOCUMENT = nil
local DOCUMENT_FORMS = nil


CreateThread(function()
    DOCUMENT_FORMS = Config.Documents[Config.Locale]
    GetAllUserForms()
    SetNuiFocus(false, false)
end)

function OpenMainMenu()
    local elements = {
        {unselectable = true, icon = "fas fa-scroll", title = _U('documents')},
        {icon = "fas fa-scroll", title = _U('public_documents'), value = "public_docs"},
        {icon = "fas fa-scroll", title = _U('job_documents'), value = "job_docs"},
        {icon = "fas fa-scroll", title = _U('saved_documents'), value = "saved_docs"}
    }

    lib.registerContext({
        id = 'DocumentMenu',
        title = _U('documents'),
        options = {
            {
                title = _U('public_documents'),
                onSelect = function(args)
                    OpenNewPublicFormMenu()
                end
            },
            {
                title = _U('job_documents'),
                onSelect = function(args)
                    OpenNewJobFormMenu()
                end
            },
            {
                title = _U('saved_documents'),
                onSelect = function(args)
                    OpenMyDocumentsMenu()
                end
            }
        }
    })

    lib.showContext('DocumentMenu')

end

function CopyFormToPlayer(aPlayer)
    TriggerServerEvent('esx_documents:CopyToPlayer', aPlayer, CURRENT_DOCUMENT)
    CURRENT_DOCUMENT = nil;
    CloseMenu()
end

AddEventHandler('CopyFormToPlayerEvent',function(aPlayer)
    TriggerServerEvent('esx_documents:CopyToPlayer', aPlayer, CURRENT_DOCUMENT)
    CURRENT_DOCUMENT = nil;
    CloseMenu()
end)


AddEventHandler('ShowToNearestPlayersDocs',function(aDocument,curDoc)
    local dinosauruslodon  = {}

    local players_clean = lib.getNearbyPlayers(GetEntityCoords(cache.ped), 3.0)
    CURRENT_DOCUMENT = aDocument
    if #players_clean > 0 then
        for i=1, #players_clean, 1 do
            dinosauruslodon[#dinosauruslodon+1] = {
                title = players_clean[i].playerName .. "[" .. tostring(players_clean[i].playerId) .. "]",
                event = "ShowDocsToPlayer",
                arg = players_clean[i].playerId
            }
        end
    end

    if players_clean == 0 then return end

    lib.registerContext({
        id = 'showToNearestContext',
        title = 'Show To Nearest Player',
        options = dinosauruslodon
    })

    lib.showContext('showToNearestContext')
end)


AddEventHandler('CopyToNearestPlayersEvent', function(aDocument,curDoc)
    local papazilalodon  = {}

    local players_clean = lib.getNearbyPlayers(GetEntityCoords(cache.ped), 3.0)
    CURRENT_DOCUMENT = aDocument
    if #players_clean > 0 then
        for i=1, #players_clean, 1 do
            papazilalodon[#papazilalodon+1] = {
                title = players_clean[i].playerName .. "[" .. tostring(players_clean[i].playerId) .. "]",
                event = "CopyFormToPlayerEvent",
                args = players_clean[i].playerId
            }
        end
    end

    if #players_clean == 0 then return end

    lib.registerContext({
        id = 'CopyToNearestContext',
        title = 'Copy To Nearest Person',
        options = papazilalodon
    })

    lib.showContext('CopyToNearestContext')
end)

function OpenNewPublicFormMenu()
    local Kontolodon = {}
    for i=1, #DOCUMENT_FORMS["public"], 1 do
        table.insert(Kontolodon,  {
            title = DOCUMENT_FORMS["public"][i].headerTitle,
            event = "CreateNewDocs",
            args = DOCUMENT_FORMS["public"][i]
        })
    end

    lib.registerContext({
        id = 'NewDocumentMenu',
        title = 'Make New Documents',
        options = Kontolodon
        
    })
    lib.showContext('NewDocumentMenu')
end

function OpenNewJobFormMenu()
    local jobmenudocs = {}

    if DOCUMENT_FORMS[ESX.PlayerData.job.name] ~= nil then
        for i=1, #DOCUMENT_FORMS[ESX.PlayerData.job.name], 1 do
            jobmenudocs[#jobmenudocs+1] = {
                title = DOCUMENT_FORMS[ESX.PlayerData.job.name][i].headerTitle,
                event = "CreateNewFormEvent",
                args = DOCUMENT_FORMS[ESX.PlayerData.job.name][i]
            }
        end
    end

    jobmenudocs[#jobmenudocs+1] = {
        title = _U("go_back"),
        onSelect = function(args)
            OpenMainMenu()
        end
    }

    lib.registerContext({
        id = 'jobdocscontext',
        title = _U('job_documents'),
        options = jobmenudocs
    })

    lib.showContext('jobdocscontext')
end


function OpenMyDocumentsMenu()
    local pepeklodon = {}

    for i=#USER_DOCUMENTS, 1, -1 do
        local date_created = ""
        if USER_DOCUMENTS[i].data.headerDateCreated ~= nil then
            date_created = USER_DOCUMENTS[i].data.headerDateCreated .. " - "
        end

        pepeklodon[#pepeklodon+1] = {
            title = date_created .. USER_DOCUMENTS[i].data.headerTitle,
            event = 'openFormSaved',
            args = USER_DOCUMENTS[i]
        }
    end

    pepeklodon[#pepeklodon+1] = {
        title = _U("go_back"),
        onSelect = function(args)
            OpenMainMenu()
        end
    }
    
    lib.registerContext({
        id = 'savedDocs',
        title = 'Saved Documents',
        options = pepeklodon
    })
    lib.showContext('savedDocs')

end

RegisterNetEvent('openFormSaved')
AddEventHandler('openFormSaved', function(aDocument, title)
    local gorilalodon = {
        {title = _U('view_bt'), event = "ViewSavedDocs", args = aDocument.data},
        {title = _U('show_bt'), event = "ShowToNearestPlayersDocs", args = aDocument.data},
        {title = _U('give_copy'), event = "CopyToNearestPlayersEvent", args = aDocument.data},
        {title = _U('delete_bt'), event = "OpenDeleteFormMenuEvent",args = aDocument},
    }
    lib.registerContext({
        id = 'openFormSavedContext',
        title = 'Test',
        options = gorilalodon
    })
    lib.showContext('openFormSavedContext')
end)

AddEventHandler('OpenDeleteFormMenuEvent',function(aDocument,curDoc)
    local deletemenu = {
        {title = _U('yes_delete'), event = "DeleteEvent", args = aDocument},
        {title = _U('go_back'), event = "openFormSaved", args = aDocument, docTitle = curDoc}
    }

    lib.registerContext({
        id = "OpenDeleteContext",
        title = "Delete Documents ?",
        options = deletemenu
    })

    lib.showContext('OpenDeleteContext')

end)

function CloseMenu()
    ESX.CloseContext()
end

function DeleteDocument(aDocument)
    local key_to_remove = nil

    ESX.TriggerServerCallback('esx_documents:deleteDocument', function (cb)
        if cb == true then
            for i=1, #USER_DOCUMENTS, 1 do
                if USER_DOCUMENTS[i].id == aDocument.id then
                    key_to_remove = i
                end
            end

            if key_to_remove ~= nil then
                table.remove(USER_DOCUMENTS, key_to_remove)
            end
            OpenMyDocumentsMenu()
        end
    end, aDocument.id)
end

AddEventHandler('DeleteEvent',function (aDocument)
    local key_to_remove = nil

    ESX.TriggerServerCallback('esx_documents:deleteDocument', function (cb)
        if cb == true then
            for i=1, #USER_DOCUMENTS, 1 do
                if USER_DOCUMENTS[i].id == aDocument.id then
                    key_to_remove = i
                end
            end

            if key_to_remove ~= nil then
                table.remove(USER_DOCUMENTS, key_to_remove)
            end
            OpenMyDocumentsMenu()
        end
    end, aDocument.id)
end)

function CreateNewForm(aDocument)
    ESX.TriggerServerCallback('esx_documents:getPlayerDetails', function (cb_player_details)
        if cb_player_details ~= nil then
            SetNuiFocus(true, true)
            aDocument.headerFirstName = cb_player_details.firstname
            aDocument.headerLastName = cb_player_details.lastname
            aDocument.headerDateOfBirth = cb_player_details.dateofbirth
            aDocument.headerJobLabel = ESX.PlayerData.job.label
            aDocument.headerJobGrade = ESX.PlayerData.job.grade_label
            aDocument.locale = Config.Locale

            SendNUIMessage({
                type = "createNewForm",
                data = aDocument
            })
        end
    end, data)
end

AddEventHandler('CreateNewFormEvent', function(aDocument)
    ESX.TriggerServerCallback('esx_documents:getPlayerDetails', function (cb_player_details)
        if cb_player_details ~= nil then
            SetNuiFocus(true, true)
            aDocument.headerFirstName = cb_player_details.firstname
            aDocument.headerLastName = cb_player_details.lastname
            aDocument.headerDateOfBirth = cb_player_details.dateofbirth
            aDocument.headerJobLabel = ESX.PlayerData.job.label
            aDocument.headerJobGrade = ESX.PlayerData.job.grade_label
            aDocument.locale = Config.Locale
            SendNUIMessage({
                type = "createNewForm",
                data = aDocument
            })
        end
    end, data)
end)

RegisterNetEvent('CreateNewDocs')
AddEventHandler('CreateNewDocs', function(aDocument)
    ESX.TriggerServerCallback('esx_documents:getPlayerDetails', function (cb_player_details)
        if cb_player_details ~= nil then
            SetNuiFocus(true, true)
            aDocument.headerFirstName = cb_player_details.firstname
            aDocument.headerLastName = cb_player_details.lastname
            aDocument.headerDateOfBirth = cb_player_details.dateofbirth
            aDocument.headerJobLabel = ESX.PlayerData.job.label
            aDocument.headerJobGrade = ESX.PlayerData.job.grade_label
            aDocument.locale = Config.Locale

            SendNUIMessage({
                type = "createNewForm",
                data = aDocument
            })
        end
    end, data)
end)

AddEventHandler('ShowDocsToPlayer', function(aPlayer)
    TriggerServerEvent('esx_documents:ShowToPlayer', aPlayer, CURRENT_DOCUMENT)
    CURRENT_DOCUMENT = nil
    CloseMenu()
end)

RegisterNetEvent('esx_documents:viewDocument')
AddEventHandler('esx_documents:viewDocument', function( data )
    ViewDocument(data)
end)


RegisterNetEvent('ViewSavedDocs')
AddEventHandler('ViewSavedDocs', function(aDocument)
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "ShowDocument",
        data = aDocument
    })
end)

RegisterNetEvent('esx_documents:copyForm')
AddEventHandler('esx_documents:copyForm', function( data )
    table.insert(USER_DOCUMENTS, data)
end)

function GetAllUserForms()
    ESX.TriggerServerCallback('esx_documents:getPlayerDocuments', function (cb_forms)
        if cb_forms ~= nil then
            USER_DOCUMENTS = cb_forms
        end
    end, data)
end

RegisterNUICallback('form_close', function()
    SetNuiFocus(false, false)
end)

RegisterNUICallback('form_submit', function(data, cb)
    CloseMenu()
    ESX.TriggerServerCallback('esx_documents:submitDocument', function (cb_form)
        if cb_form ~= nil then
            table.insert(USER_DOCUMENTS, cb_form)
        end
    end, data)
    SetNuiFocus(false, false)
end)

-- Command/Open menu
RegisterCommand("openDocuments", function()
    OpenMainMenu()
end)

RegisterKeyMapping("openDocuments", "Open Documents", "keyboard", "F10")
TriggerEvent('chat:removeSuggestion', '/openDocuments')
