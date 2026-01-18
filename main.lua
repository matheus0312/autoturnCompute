-- todo
-- - change presentation of widget to be shown below autoturn
-- - show page duration on menu
-- - add checkbox on the menu to activate plugin


local WidgetContainer = require("ui/widget/container/widgetcontainer")
local UIManager = require("ui/uimanager")
local logger = require("logger")
local _ = require("gettext")
local T = require("ffi/util").template

local autoturnCompute = WidgetContainer:extend{
    name = "autoturn_compute",
    is_doc_only = true,
    
    -- State variables
    current_page = nil,
    page_start_time = nil,
    duration_history = {},
    max_history_size = 10,
    average_duration = 0,
    std_dev = 0,
    popup_shown = false,
    enabled = false,
}

function autoturnCompute:init()
    self.ui.menu:registerToMainMenu(self)
    
    -- Initialize variables to defaults.
    -- DO NOT call self.ui.document methods here (causes crash).
    self.current_page = nil
    self.page_start_time = os.time()
    self.duration_history = {}
    self.std_dev = 0
    self.popup_shown = false
    self.enabled = false
    
    logger.debug("autoturnCompute:init - Plugin loaded")
end

-- This function is called automatically when the document engine is fully loaded
function autoturnCompute:onReaderReady()
    self.current_page = self.ui:getCurrentPage()
    self.page_start_time = os.time()
    
    logger.debug("autoturnCompute:onReaderReady - Initialized. Current Page:", self.current_page)
end

function autoturnCompute:updateAverage()
    if #self.duration_history == 0 then
        self.average_duration = 0
        logger.debug("autoturnCompute:updateAverage - initialize duration average to 0")
        return
    end
    local sum = 0
    for _, ppm in ipairs(self.duration_history) do
        sum = sum + ppm
    end
    self.average_duration = sum / #self.duration_history
end

function autoturnCompute:computeStandardDeviation()
    if #self.duration_history < 2 then
        self.std_dev = 0
        return
    end

    local sum_of_squared_differences = 0
    for _, duration in ipairs(self.duration_history) do
        local difference = duration - self.average_duration
        sum_of_squared_differences = sum_of_squared_differences + (difference * difference)
    end

    local variance = sum_of_squared_differences / #self.duration_history
    self.std_dev = math.sqrt(variance)
    logger.debug("autoturnCompute:computeStandardDeviation - Standard Deviation:", self.std_dev)
end

function autoturnCompute:onPageUpdate(new_page)
    if not self.enabled then return end
    local now = os.time()
    
    -- Calculate stats for the page we just FINISHED (self.current_page)
    if self.current_page and self.page_start_time and self.current_page ~= new_page then
        local duration = os.difftime(now, self.page_start_time)
        
        logger.debug("autoturnCompute:onPageUpdate - Last Page Duration: ", duration)
        
        if duration > 5 and duration < 600 then
                
            table.insert(self.duration_history, duration)
            if #self.duration_history > self.max_history_size then
                table.remove(self.duration_history, 1)
                    
                logger.debug("autoturnCompute:onPageUpdate - remove oldest history entry")
            end
                
            self:updateAverage()
            self:computeStandardDeviation()
            logger.debug("autoturnCompute:onPageUpdate - Page", self.current_page, "Time:", duration, "Avg:", self.average_duration)

            local durationSize = #self.duration_history
            logger.debug("autoturnCompute:onPageUpdate - Duration History Size:", durationSize)

            if not self.popup_shown and #self.duration_history == self.max_history_size then
                local InfoMessage = require("ui/widget/infomessage")
                UIManager:show(InfoMessage:new{
                    text = T("Reading speed computed: %1 (±%2) seconds per page", math.floor(self.average_duration), math.floor(self.std_dev or 0))
                })
                self.popup_shown = true
            end
        else
            logger.debug("autoturnCompute:onPageUpdate - page duration out of bounds, skipping.")
        end
    end
    
    -- Setup for the NEW page
    self.current_page = new_page
    self.page_start_time = now
    
    logger.debug("autoturnCompute:onPageUpdate - current page number:", new_page)
end

function autoturnCompute:onSuspend()
    self.page_start_time = nil    
end

function autoturnCompute:onResume()
    self.page_start_time = os.time()
end

function autoturnCompute:addToMainMenu(menu_items)
    menu_items.autoturn_compute = {
        sorting_hint = "navi",
        text = _("Autoturn Compute"),
        sub_item_table = {
            {
                text = _("Enabled"),
                checked_func = function() return self.enabled end,
                callback = function() self.enabled = not self.enabled end,
            },
            {
                text_func = function()
                    return T(_("Avg Page Duration: %1 (±%2)"), math.floor(self.average_duration), math.floor(self.std_dev or 0))
                end,
                callback = function()
                    local InfoMessage = require("ui/widget/infomessage")
                    UIManager:show(InfoMessage:new{
                        text = T(_("Based on the last %1 pages.\n\nLatest Page Duration: %2 seconds Average Page Duration: %3 seconds\nStandard Deviation: %4 seconds"), 
                            #self.duration_history,
                            self.duration_history[#self.duration_history] and math.floor(self.duration_history[#self.duration_history]) or 0,
                            math.floor(self.average_duration),
                            self.std_dev and math.floor(self.std_dev) or 0
                        ),
                    })
                end
            },
            {
                text = _("Reset History"),
                callback = function()
                    self.duration_history = {}
                    self.average_duration = 0
                    self.std_dev = 0
                    self.popup_shown = false
                    self.page_start_time = os.time()
                    local InfoMessage = require("ui/widget/infomessage")
                    UIManager:show(InfoMessage:new{
                        text = _("Autoturn Compute history has been reset."),
                    })
                end
            }
        }
    }
end

return autoturnCompute
