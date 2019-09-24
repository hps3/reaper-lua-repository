--[[
-- Toggle online/offline state of named fx
-- workaround when working with multiple reaper project tabs
---- only one set of vst Console 1's can be active otherwise the Console 1 mixer will be able to see the other set of vsts in the non-active projects
---- Solution - Turn the status to offline for all sets of vst Console 1's in non-active projects and confirming they are only active in the active/focused project.
---- Additional Solution - Ctrl+B to open Project Bay right click status of Console 1 and set to active or offline depending on the project you want to use.
--]]


--[[
-- function get_totalTrackCount()
-- No Inputs or Outputs
-- Sets global variable track_count to total number of tracks in active project
-------------------REAPER API REFERENCE------------------------
--Lua: integer reaper.CountTracks(ReaProject proj)
--  count the number of tracks in the project (proj=0 for active project)
--Lua: integer reaper.GetNumTracks()
-------------------REAPER API REFERENCE------------------------
 ]]
function get_totalTrackCount()
    track_count = reaper.CountTracks(0)
end
--[[
-- function toggleFxState(fullPluginName)
-- Input: fullPluginName
-- Output: NONE
---- loop through tracks searching through each fx slot for the vst plugin with the name defined in the main function
---- toggle the Status from offline to active and vice versa
-------------------REAPER API REFERENCE------------------------
--Lua: MediaTrack reaper.GetTrack(ReaProject proj, integer trackidx)
--  get a track from a project by track count (zero-based) (proj=0 for active project)
--Lua: reaper.SetTrackSelected(MediaTrack track, boolean selected)
--Lua: integer reaper.TrackFX_GetCount(MediaTrack track)
--Lua: boolean retval, string buf = reaper.TrackFX_GetFXName(MediaTrack track, integer fx, string buf)
--Lua: reaper.Main_OnCommand(integer command, integer flag)
--  Lua: integer reaper.NamedCommandLookup(string command_name)
--      Get the command ID number for named command that was registered by an extension such as "_SWS_ABOUT" or "_113088d11ae641c193a2b7ede3041ad5" for a ReaScript or a custom action.
--SWS/S&M: Set selected FX offline for selected track(s)S&M_FXOFF_SETOFFSEL
--SWS/S&M: Set selected FX online for selected track(s)S&M_FXOFF_SETONSEL
--SWS/S&M: Toggle FX [1 thru 8] online/offline for selected track(s)S&M_FXOFF1 ...S&M_FXOFF8
--SWS/S&M: Toggle selected FX online/offline for selected track(s)S&M_FXOFFSEL
--SWS/S&M: Set FX [1 thru 8] offline for selected track(s)S&M_FXOFF_SETOFF1 ...S&M_FXOFF_SETOFF8
--SWS/S&M: Set FX [1 thru 8] online for selected track(s)S&M_FXOFF_SETON1 ...S&M_FXOFF_SETON8
--SWS: Switch to project tab [1 thru 10]SWS_PROJTAB2 ...SWS PROJTAB10
-------------------REAPER API REFERENCE------------------------
--]]
function toggleFxState(fullPluginName)
    for i = 0, track_count - 1, 1 do
        tr = reaper.GetTrack(0, i)
        reaper.SetTrackSelected(tr, 1)
        local totalFxCount = reaper.TrackFX_GetCount(tr)
        for j = 0, totalFxCount - 1, 1 do
            local fx_name_retval, fx_name = reaper.TrackFX_GetFXName(tr, j, "")
            if fx_name == fullPluginName then
                commandName = '_S&M_FXOFF' .. (j + 1)
                --commandName = '_S&M_FXOFF_SETOFF' .. (j + 1)
                --commandName = '_S&M_FXOFF_SETON' .. (j + 1)
                reaper.Main_OnCommand(reaper.NamedCommandLookup(commandName),0)
            end
        end
        reaper.SetTrackSelected(tr, 0)
    end
end
--
--[[
-- function main()
-- NO INPUTS OR OUTPUTS
-- Sets local variable vstPluginName with the desired plugin name(user defined hard-coded)
-- executes get_totalTrackCount() and toggleFxState(vstPluginName)
-- Sets Undo History value to Toggle Console 1 ON/OFFLINE
---------------------REAPER API REFERENCE------------------------
--Lua: reaper.Undo_EndBlock(string descchange, integer extraflags)
--  call to end the block,with extra flags if any,and a description
---------------------REAPER API REFERENCE------------------------
 ]]
function main()
    reaper.Undo_BeginBlock()

    reaper.Main_OnCommandEx(40297, 0 , 0)
    local vstPluginName = 'VST3: Console 1 (Softube)'
    get_totalTrackCount()
    toggleFxState(vstPluginName)

    reaper.Undo_EndBlock("Toggle Console 1 ON/OFFLINE", 2)
end
--[[
Execute main function
--]]
main()
