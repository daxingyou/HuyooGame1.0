local Common = require("common.Common")
local StaticData = require("app.static.StaticData")
local UserData = require("app.user.UserData")
local EventType = require("common.EventType")
local EventMgr = require("common.EventMgr")
local NetMgr = require("common.NetMgr")
local NetMsgId = require("common.NetMsgId")
local EventType = require("common.EventType")
local Bit = require("common.Bit")
local GameDesc = require("common.GameDesc")

local RoomCreateLayer = class("RoomCreateLayer", cc.load("mvc").ViewBase)

function RoomCreateLayer:onEnter()
    EventMgr:registListener(EventType.SUB_CL_FRIENDROOM_CONFIG,self,self.SUB_CL_FRIENDROOM_CONFIG)
    EventMgr:registListener(EventType.SUB_CL_FRIENDROOM_CONFIG_END,self,self.SUB_CL_FRIENDROOM_CONFIG_END)
end

function RoomCreateLayer:onExit()
    EventMgr:unregistListener(EventType.SUB_CL_FRIENDROOM_CONFIG,self,self.SUB_CL_FRIENDROOM_CONFIG)
    EventMgr:unregistListener(EventType.SUB_CL_FRIENDROOM_CONFIG_END,self,self.SUB_CL_FRIENDROOM_CONFIG_END)
end

function RoomCreateLayer:onCleanup()

end

function RoomCreateLayer:onCreate(parameter)
    self.wKindID  = parameter[1]
    self.showType = parameter[2]
    self.dwClubID = parameter[3]
    if CHANNEL_ID == 6 or CHANNEL_ID == 7 then
        self:initUI67()
    else
        self:initUI()
    end
    if self.showType == 3 then
        self.tableFriendsRoomParams = {[1] = {wGameCount = 1}}
        self:SUB_CL_FRIENDROOM_CONFIG_END()
    else
        UserData.Game:sendMsgGetFriendsRoomParam(self.wKindID)
    end
end

function RoomCreateLayer:initUI()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("RoomCreateLayer51.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    self.recordCreateParameter = UserData.Game:readCreateParameter(self.wKindID)
    if self.recordCreateParameter == nil then
        self.recordCreateParameter = {}
    end
    local uiListView_create = ccui.Helper:seekWidgetByName(self.root,"ListView_create")
    local uiButton_create = ccui.Helper:seekWidgetByName(self.root,"Button_create")
    Common:addTouchEventListener(uiButton_create,function() self:onEventCreate(0) end)
    local uiButton_guild = ccui.Helper:seekWidgetByName(self.root,"Button_guild")
    Common:addTouchEventListener(uiButton_guild,function() self:onEventCreate(1) end)
    local uiButton_help = ccui.Helper:seekWidgetByName(self.root,"Button_help")
    Common:addTouchEventListener(uiButton_help,function() self:onEventCreate(-1) end)
    local uiButton_settings = ccui.Helper:seekWidgetByName(self.root,"Button_settings")
    Common:addTouchEventListener(uiButton_settings,function() self:onEventCreate(-2) end)
    if self.showType ~= nil and self.showType == 1 then
        uiListView_create:removeItem(0)
        uiListView_create:removeItem(0)
        uiListView_create:removeItem(0)
        
    elseif self.showType ~= nil and self.showType == 3 then
        uiListView_create:removeItem(0)
        uiListView_create:removeItem(0)
        uiListView_create:removeItem(0)

    elseif self.showType ~= nil and self.showType == 2 then
        uiListView_create:removeItem(0)
        uiListView_create:removeItem(1)
        uiListView_create:removeItem(1)
    else
        uiListView_create:removeItem(3)
        uiListView_create:removeItem(0)

        if StaticData.Hide[CHANNEL_ID].btn11 ~= 1 then 
            uiListView_create:removeItem(uiListView_create:getIndex(uiButton_help))
        end  
    end
    uiListView_create:refreshView()
    uiListView_create:setContentSize(cc.size(uiListView_create:getInnerContainerSize().width,uiListView_create:getInnerContainerSize().height))
    uiListView_create:setPositionX(uiListView_create:getParent():getContentSize().width/2)
    local uiListView_parameterList = ccui.Helper:seekWidgetByName(self.root,"ListView_parameterList")
    --选择局数
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(0),"ListView_parameter"):getItems()
    uiListView_parameterList:getItem(0):setVisible(false)
    Common:addCheckTouchEventListener(items)
    --选择底注
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(1),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items)
    if self.recordCreateParameter["bBettingType"] ~= nil and self.recordCreateParameter["bBettingType"] == 2 then
        items[2]:setBright(true)
    else
        items[1]:setBright(true)
    end
    --选择庄家
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(2),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,false,function(index) 
        local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(3),"ListView_parameter"):getItems()
        local var = items[1]
        if index == 2 then
            var:setColor(cc.c3b(255,255,255))
            var:setEnabled(true)
        else
            var:setColor(cc.c3b(170,170,170))
            var:setEnabled(false)
            var:setBright(false)
        end

        -- 控制搓牌
        local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(7),"ListView_parameter"):getItems()
        local var = items[1]
        if index == 2 then
            var:setVisible(true)
            var:setEnabled(true)
        else
            var:setVisible(false)
            var:setEnabled(false)
            var:setBright(false)
        end
    end)
    if self.showType == 3 then
        for key, var in pairs(items) do
            var:setColor(cc.c3b(170,170,170))
            var:setEnabled(false)
            var:setBright(false)
        end
        items[4]:setBright(true)
        items[4]:setColor(cc.c3b(255,255,255))
        items[4]:setEnabled(true)
    else
        if self.recordCreateParameter["bBankerType"] ~= nil and self.recordCreateParameter["bBankerType"] == 0 then
            items[1]:setBright(true)
        elseif self.recordCreateParameter["bBankerType"] ~= nil and self.recordCreateParameter["bBankerType"] == 1 then
            items[2]:setBright(true)
        elseif self.recordCreateParameter["bBankerType"] ~= nil and self.recordCreateParameter["bBankerType"] == 3 then
            items[4]:setBright(true)
        elseif self.recordCreateParameter["bBankerType"] ~= nil and self.recordCreateParameter["bBankerType"] == 4 then
            items[5]:setBright(true)
        else
            items[3]:setBright(true)
        end
    end
    --特殊选项
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(3),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,true,function(index) 
        if index == 3 then
            local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(3),"ListView_parameter"):getItems() 
            local target = items[index]
            if target:isBright() then
                local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(5),"ListView_parameter"):getItems()
                for key, var in pairs(items) do
                    var:setColor(cc.c3b(170,170,170))
                    var:setEnabled(false)
                    var:setBright(false)
                end 
                local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(4),"ListView_parameter"):getItems()
                for key, var in pairs(items) do
                    var:setColor(cc.c3b(170,170,170))
                    var:setEnabled(false)
                    var:setBright(false)
                end 
            else
                local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(5),"ListView_parameter"):getItems()
                for key, var in pairs(items) do
                    var:setColor(cc.c3b(255,255,255))
                    var:setEnabled(true)
                    if key == 3 then
                        var:setBright(true)
                    else
                        var:setBright(false)
                    end
                end
                local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(4),"ListView_parameter"):getItems()
                for key, var in pairs(items) do
                    var:setColor(cc.c3b(255,255,255))
                    var:setEnabled(true)
                    var:setBright(false)
                end 
            end
        end
    end)
    if self.recordCreateParameter["bPush"] ~= nil and self.recordCreateParameter["bPush"] == 1 then
        items[1]:setBright(true)
    else
        items[1]:setBright(false)
    end
    if self.recordCreateParameter["bBankerType"] == nil or self.recordCreateParameter["bBankerType"] ~= 1 then
        items[1]:setColor(cc.c3b(170,170,170))
        items[1]:setEnabled(false)
        items[1]:setBright(false)
    end
    if self.recordCreateParameter["bNoFlower"] ~= nil and self.recordCreateParameter["bNoFlower"] == 1 then
        items[2]:setBright(true)
    else
        items[2]:setBright(false)
    end
    if self.recordCreateParameter["bSettlementType"] ~= nil and self.recordCreateParameter["bSettlementType"] == 0 then
        items[3]:setBright(true)
    end
    if self.recordCreateParameter["bCanPlayingJoin"] ~= nil and self.recordCreateParameter["bCanPlayingJoin"] == 0 then
        items[4]:setBright(false)
    else
        items[4]:setBright(true)
    end
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(4),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,true)
    if self.recordCreateParameter["bNiuType_Flush"] ~= nil and self.recordCreateParameter["bNiuType_Flush"] == 1 then
        items[1]:setBright(true)
    else
        items[1]:setBright(false)
    end
    if self.recordCreateParameter["bNiuType_Gourd"] ~= nil and self.recordCreateParameter["bNiuType_Gourd"] == 1 then
        items[2]:setBright(true)
    else
        items[2]:setBright(false)
    end  
    if self.recordCreateParameter["bNiuType_SameColor"] ~= nil and self.recordCreateParameter["bNiuType_SameColor"] == 1 then
        items[3]:setBright(true)
    else
        items[3]:setBright(false)
    end 
    if self.recordCreateParameter["bNiuType_Straight"] ~= nil and self.recordCreateParameter["bNiuType_Straight"] == 1 then
        items[4]:setBright(true)
    else
        items[4]:setBright(false)
    end  
    if self.recordCreateParameter["bSettlementType"] ~= nil and self.recordCreateParameter["bSettlementType"] == 0 then
        for key, var in pairs(items) do
            var:setColor(cc.c3b(170,170,170))
            var:setEnabled(false)
        end
    end 
    --选择赔率
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(5),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items)
    if self.recordCreateParameter["bSettlementType"] ~= nil and self.recordCreateParameter["bSettlementType"] == 1 then
        items[1]:setBright(true)
    elseif self.recordCreateParameter["bSettlementType"] ~= nil and self.recordCreateParameter["bSettlementType"] == 2 then
        items[2]:setBright(true)
    elseif self.recordCreateParameter["bSettlementType"] ~= nil and self.recordCreateParameter["bSettlementType"] == 0 then
        for key, var in pairs(items) do
            var:setColor(cc.c3b(170,170,170))
            var:setEnabled(false)
        end
    else
        items[3]:setBright(true)
    end
    --庄家倍数
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(6),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items)
    if self.recordCreateParameter["bMultiple"] ~= nil and self.recordCreateParameter["bMultiple"] == 1 then
        items[1]:setBright(true)
    elseif self.recordCreateParameter["bMultiple"] ~= nil and self.recordCreateParameter["bMultiple"] == 2 then
        items[2]:setBright(true)
    elseif self.recordCreateParameter["bMultiple"] ~= nil and self.recordCreateParameter["bMultiple"] == 3 then
        items[3]:setBright(true)
    else
        items[4]:setBright(true)
    end    

    --搓牌
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(7),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,true)
    if self.recordCreateParameter["bBankerType"] == nil or self.recordCreateParameter["bBankerType"] ~= 1 then
        items[1]:setBright(false)
        items[1]:setVisible(false)
    elseif self.recordCreateParameter["bCuopai"] ~= nil and self.recordCreateParameter["bCuopai"] == 1 then
        items[1]:setBright(true)
        items[1]:setVisible(true)
    end    
end

function RoomCreateLayer:initUI67()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("RoomCreateLayer51_67.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    self.recordCreateParameter = UserData.Game:readCreateParameter(self.wKindID)
    if self.recordCreateParameter == nil then
        self.recordCreateParameter = {}
    end
    local uiListView_create = ccui.Helper:seekWidgetByName(self.root,"ListView_create")
    local uiButton_create = ccui.Helper:seekWidgetByName(self.root,"Button_create")
    Common:addTouchEventListener(uiButton_create,function() self:onEventCreate(0) end)
    local uiButton_guild = ccui.Helper:seekWidgetByName(self.root,"Button_guild")
    Common:addTouchEventListener(uiButton_guild,function() self:onEventCreate(1) end)
    local uiButton_help = ccui.Helper:seekWidgetByName(self.root,"Button_help")
    Common:addTouchEventListener(uiButton_help,function() self:onEventCreate(-1) end)
    local uiButton_settings = ccui.Helper:seekWidgetByName(self.root,"Button_settings")
    Common:addTouchEventListener(uiButton_settings,function() self:onEventCreate(-2) end)

    if self.showType ~= nil and self.showType == 1 then
        uiListView_create:removeItem(0)
        uiListView_create:removeItem(0)
        uiListView_create:removeItem(0)
        
    elseif self.showType ~= nil and self.showType == 3 then
        uiListView_create:removeItem(0)
        uiListView_create:removeItem(0)
        uiListView_create:removeItem(0)

    elseif self.showType ~= nil and self.showType == 2 then
        uiListView_create:removeItem(0)
        uiListView_create:removeItem(1)
        uiListView_create:removeItem(1)
    else
        uiListView_create:removeItem(3)
        uiListView_create:removeItem(0)

        if StaticData.Hide[CHANNEL_ID].btn11 ~= 1 then 
            uiListView_create:removeItem(uiListView_create:getIndex(uiButton_help))
        end  
    end

    uiListView_create:refreshView()
    uiListView_create:setContentSize(cc.size(uiListView_create:getInnerContainerSize().width,uiListView_create:getInnerContainerSize().height))
    uiListView_create:setPositionX(uiListView_create:getParent():getContentSize().width/2)
    local uiListView_parameterList = ccui.Helper:seekWidgetByName(self.root,"ListView_parameterList")
    --选择局数
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(0),"ListView_parameter"):getItems()
    uiListView_parameterList:getItem(0):setVisible(false)
    Common:addCheckTouchEventListener(items)
    --选择底注
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(1),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items)
    items[1]:setBright(true)
    --选择庄家
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(2),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,false,function(index) 
        -- 控制搓牌
        local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(7),"ListView_parameter"):getItems()
        local var = items[1]
        if index == 2 then
            var:setVisible(true)
            var:setEnabled(true)
        else
            var:setVisible(false)
            var:setEnabled(false)
            var:setBright(false)
        end
    end)
    if self.recordCreateParameter["bBankerType"] ~= nil and self.recordCreateParameter["bBankerType"] == 2 then
        items[2]:setBright(true)
    else
        items[1]:setBright(true)
    end
    --特殊选项
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(3),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,true)
    if self.recordCreateParameter["bCanPlayingJoin"] ~= nil and self.recordCreateParameter["bCanPlayingJoin"] == 1 then
        items[1]:setBright(true)
    else
        items[1]:setBright(false)
    end
    --选择赔率
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(4),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items)
    if self.recordCreateParameter["bSettlementType"] ~= nil and self.recordCreateParameter["bSettlementType"] == 1 then
        items[1]:setBright(true)
    elseif self.recordCreateParameter["bSettlementType"] ~= nil and self.recordCreateParameter["bSettlementType"] == 2 then
        items[2]:setBright(true)
    elseif self.recordCreateParameter["bSettlementType"] ~= nil and self.recordCreateParameter["bSettlementType"] == 0 then
        for key, var in pairs(items) do
            var:setColor(cc.c3b(170,170,170))
            var:setEnabled(false)
        end
    else
        items[3]:setBright(true)
    end
    --庄家倍数
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(5),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items)
    if self.recordCreateParameter["bMultiple"] ~= nil and self.recordCreateParameter["bMultiple"] == 1 then
        items[1]:setBright(true)
    elseif self.recordCreateParameter["bMultiple"] ~= nil and self.recordCreateParameter["bMultiple"] == 2 then
        items[2]:setBright(true)
    elseif self.recordCreateParameter["bMultiple"] ~= nil and self.recordCreateParameter["bMultiple"] == 3 then
        items[3]:setBright(true)
    else
        items[4]:setBright(true)
    end  
    
    
    --搓牌
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(6),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,true)
    if self.recordCreateParameter["bBankerType"] == nil or self.recordCreateParameter["bBankerType"] ~= 1 then
        items[1]:setBright(false)
        items[1]:setVisible(false)
    elseif self.recordCreateParameter["bCuopai"] ~= nil and self.recordCreateParameter["bCuopai"] == 1 then
        items[1]:setBright(true)
        items[1]:setVisible(true)
    end   
end

function RoomCreateLayer:SUB_CL_FRIENDROOM_CONFIG(event)
    local data = event._usedata
    if data.wKindID ~= self.wKindID then
        return
    end
    if self.tableFriendsRoomParams == nil then
        self.tableFriendsRoomParams = {}
    end
    self.tableFriendsRoomParams[data.dwIndexes] = data
end

function RoomCreateLayer:SUB_CL_FRIENDROOM_CONFIG_END(event)
    if self.tableFriendsRoomParams == nil then
        return
    end
    local uiListView_parameterList = ccui.Helper:seekWidgetByName(self.root,"ListView_parameterList")
    local uiListView_parameter = uiListView_parameterList:getItem(0)
    uiListView_parameter:setVisible(true)
    local items = ccui.Helper:seekWidgetByName(uiListView_parameter,"ListView_parameter"):getItems()
    local isFound = false
    for key, var in pairs(items) do
        local data = self.tableFriendsRoomParams[key]
    	if data then
            local uiText_desc = ccui.Helper:seekWidgetByName(var,"Text_desc")
            uiText_desc:setString(string.format("%d局",data.wGameCount))
            local uiText_addition = ccui.Helper:seekWidgetByName(var,"Text_addition")
            if data.dwExpendType == 1 then
                uiText_addition:setString(string.format("金币x%d",data.dwExpendCount))
            elseif data.dwExpendType == 2 then
                uiText_addition:setString(string.format("元宝x%d",data.dwExpendCount))
            elseif data.dwExpendType == 3 then
                uiText_addition:setString(string.format("(%sx%d)",StaticData.Items[data.dwSubType].name,data.dwExpendCount))   
            else
                uiText_addition:setString("(无消耗)")
            end
            if isFound == false and self.recordCreateParameter["wGameCount"] ~= nil and self.recordCreateParameter["wGameCount"] == data.wGameCount then
                var:setBright(true)
                isFound = true
            end
    	else
    	   var:setBright(false)
    	   var:setVisible(false)
    	end
    end
    if isFound == false and items[1]:isVisible() then
        items[1]:setBright(true)
    end
end

function RoomCreateLayer:onEventCreate(nTableType)
    NetMgr:getGameInstance():closeConnect()
    self.tableParameter = {}
    if CHANNEL_ID == 6 or CHANNEL_ID == 7 then
        self:setParameter67()
    else
        self:setParameter()
    end
   if self.showType ~= 2 and (nTableType == TableType_FriendRoom or nTableType == TableType_HelpRoom) then
        --普通创房和代开需要判断金币
        local uiListView_parameterList = ccui.Helper:seekWidgetByName(self.root,"ListView_parameterList")
        local uiListView_parameter = uiListView_parameterList:getItem(0)
        local items = ccui.Helper:seekWidgetByName(uiListView_parameter,"ListView_parameter"):getItems()
        for key, var in pairs(items) do
            if var:isBright() then
                local data = self.tableFriendsRoomParams[key]
                if data.dwExpendType == 0 then--无消耗
                elseif data.dwExpendType == 1 then--金币
                    if UserData.User.dwGold  < data.dwExpendCount then
                        if  StaticData.Hide[CHANNEL_ID].btn8 == 1 and StaticData.Hide[CHANNEL_ID].btn9 == 1  then
                            require("common.MsgBoxLayer"):create(1,nil,"您的金币不足,请前往商城充值？",function() require("common.SceneMgr"):switchOperation(require("app.MyApp"):create(2):createView("MallLayer")) end)
                        else
                            require("common.MsgBoxLayer"):create(1,nil,"您的金币不足，请联系会长购买！",function() require("common.SceneMgr"):switchOperation(require("app.MyApp"):create():createView("GuilLayer"))  end)
                        end
                        return
                end  
                elseif data.dwExpendType == 2 then--元宝
                    if UserData.User.dwIngot  < data.dwExpendCount then
                        if  StaticData.Hide[CHANNEL_ID].btn8 == 1 and StaticData.Hide[CHANNEL_ID].btn9 == 1  then
                            require("common.MsgBoxLayer"):create(1,nil,"您的元宝不足,请前往商城购买？",function() require("common.SceneMgr"):switchOperation(require("app.MyApp"):create(2):createView("MallLayer")) end)
                        else
                            require("common.MsgBoxLayer"):create(1,nil,"您的元宝不足，请联系会长购买！",function() require("common.SceneMgr"):switchOperation(require("app.MyApp"):create():createView("GuilLayer"))  end)
                        end
                        return
                end 
                elseif data.dwExpendType == 3 then--道具
                    local itemCount = UserData.Bag:getBagPropCount(data.dwSubType)
                    if itemCount < data.dwExpendCount then
                        if  StaticData.Hide[CHANNEL_ID].btn8 == 1 and StaticData.Hide[CHANNEL_ID].btn9 == 1  then
                            require("common.MsgBoxLayer"):create(1,nil,"您的道具不足,请前往商城购买?",function() require("common.SceneMgr"):switchOperation(require("app.MyApp"):create(2):createView("MallLayer")) end)
                        else
                            require("common.MsgBoxLayer"):create(0,nil,"您的道具不足!")
                        end
                        return
                    end
                else
                    return
                end
                break
            end
        end
    end

    UserData.Game:saveCreateParameter(self.wKindID,self.tableParameter)

    --亲友圈自定义创房
    if self.showType == 2 then
        local uiButton_create = ccui.Helper:seekWidgetByName(self.root,"Button_create")
        uiButton_create:removeAllChildren()
        uiButton_create:addChild(require("app.MyApp"):create(TableType_ClubRoom,1,self.wKindID,self.tableParameter.wGameCount,self.dwClubID,self.tableParameter):createView("InterfaceCreateRoomNode"))
        return
    end 
    --设置亲友圈   
    if nTableType == TableType_ClubRoom then
        EventMgr:dispatch(EventType.EVENT_TYPE_SETTINGS_CLUB_PARAMETER,{wKindID = self.wKindID,wGameCount = self.tableParameter.wGameCount,tableParameter = self.tableParameter})      
        return
    end

    local uiButton_create = ccui.Helper:seekWidgetByName(self.root,"Button_create")
    uiButton_create:removeAllChildren()
    uiButton_create:addChild(require("app.MyApp"):create(nTableType,0,self.wKindID,self.tableParameter.wGameCount,UserData.Guild.dwPresidentID,self.tableParameter):createView("InterfaceCreateRoomNode"))

end

function RoomCreateLayer:setParameter()
    local uiListView_parameterList = ccui.Helper:seekWidgetByName(self.root,"ListView_parameterList")
    --选择局数
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(0),"ListView_parameter"):getItems()
    if items[1]:isBright() and self.tableFriendsRoomParams[1] then
        self.tableParameter.wGameCount = self.tableFriendsRoomParams[1].wGameCount
    elseif items[2]:isBright() and self.tableFriendsRoomParams[2] then
        self.tableParameter.wGameCount = self.tableFriendsRoomParams[2].wGameCount
    elseif items[3]:isBright() and self.tableFriendsRoomParams[3] then
        self.tableParameter.wGameCount = self.tableFriendsRoomParams[3].wGameCount
    else
        return
    end
    --选择底注
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(1),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        self.tableParameter.bBettingType = 1
    elseif items[2]:isBright() then
        self.tableParameter.bBettingType = 2
    else
        return
    end
    --选择庄家
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(2),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        self.tableParameter.bBankerType = 0
    elseif items[2]:isBright() then
        self.tableParameter.bBankerType = 1
    elseif items[3]:isBright() then
        self.tableParameter.bBankerType = 2
    elseif items[4]:isBright() then
        self.tableParameter.bBankerType = 3
    elseif items[5]:isBright() then
        self.tableParameter.bBankerType = 4
    else
        return
    end
    --特殊选项
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(3),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        self.tableParameter.bPush = 1
    else
        self.tableParameter.bPush = 0
    end
    if items[2]:isBright() then
        self.tableParameter.bNoFlower = 1
    else
        self.tableParameter.bNoFlower = 0
    end
    if items[4]:isBright() then
        self.tableParameter.bCanPlayingJoin = 1
    else
        self.tableParameter.bCanPlayingJoin = 0
    end
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(4),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        self.tableParameter.bNiuType_Flush = 1
    else
        self.tableParameter.bNiuType_Flush = 0
    end
    if items[2]:isBright() then
        self.tableParameter.bNiuType_Gourd = 1
    else
        self.tableParameter.bNiuType_Gourd = 0
    end
    if items[3]:isBright() then
        self.tableParameter.bNiuType_SameColor = 1
    else
        self.tableParameter.bNiuType_SameColor = 0
    end
    if items[4]:isBright() then
        self.tableParameter.bNiuType_Straight = 1
    else
        self.tableParameter.bNiuType_Straight = 0
    end
    --选择赔率
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(5),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        self.tableParameter.bSettlementType = 1
    elseif items[2]:isBright() then
        self.tableParameter.bSettlementType = 2
    elseif items[3]:isBright() then
        self.tableParameter.bSettlementType = 3
    else
        self.tableParameter.bSettlementType = 0
    end
    --庄家倍数
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(6),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        self.tableParameter.bMultiple = 1
    elseif items[2]:isBright() then
        self.tableParameter.bMultiple = 2
    elseif items[3]:isBright() then
        self.tableParameter.bMultiple = 3
    elseif items[4]:isBright() then
        self.tableParameter.bMultiple = 4
    else
        return
    end 
    self.tableParameter.bPlayerCount = 6
    if self.showType == 3 then
        self.tableParameter.bPlayerCount = 2
    end

    --搓牌
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(7),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        self.tableParameter.bCuopai = 1
    else
        self.tableParameter.bCuopai = 0
    end
end

function RoomCreateLayer:setParameter67()
    local uiListView_parameterList = ccui.Helper:seekWidgetByName(self.root,"ListView_parameterList")
    --选择局数
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(0),"ListView_parameter"):getItems()
    if items[1]:isBright() and self.tableFriendsRoomParams[1] then
        self.tableParameter.wGameCount = self.tableFriendsRoomParams[1].wGameCount
    elseif items[2]:isBright() and self.tableFriendsRoomParams[2] then
        self.tableParameter.wGameCount = self.tableFriendsRoomParams[2].wGameCount
    elseif items[3]:isBright() and self.tableFriendsRoomParams[3] then
        self.tableParameter.wGameCount = self.tableFriendsRoomParams[3].wGameCount
    else
        return
    end
    --选择底注
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(1),"ListView_parameter"):getItems()
    self.tableParameter.bBettingType = 1
    --选择庄家
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(2),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        self.tableParameter.bBankerType = 1
    elseif items[2]:isBright() then
        self.tableParameter.bBankerType = 2
    else
        return
    end
    --特殊选项
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(3),"ListView_parameter"):getItems()
    self.tableParameter.bPush = 0
    self.tableParameter.bNoFlower = 0
    if items[1]:isBright() then
        self.tableParameter.bCanPlayingJoin = 1
    else
        self.tableParameter.bCanPlayingJoin = 0
    end
    self.tableParameter.bNiuType_Flush = 0
    self.tableParameter.bNiuType_Gourd = 0
    self.tableParameter.bNiuType_SameColor = 0
    self.tableParameter.bNiuType_Straight = 0
    --选择赔率
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(4),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        self.tableParameter.bSettlementType = 1
    elseif items[2]:isBright() then
        self.tableParameter.bSettlementType = 2
    elseif items[3]:isBright() then
        self.tableParameter.bSettlementType = 3
    else
        self.tableParameter.bSettlementType = 0
    end
    --庄家倍数
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(5),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        self.tableParameter.bMultiple = 1
    elseif items[2]:isBright() then
        self.tableParameter.bMultiple = 2
    elseif items[3]:isBright() then
        self.tableParameter.bMultiple = 3
    elseif items[4]:isBright() then
        self.tableParameter.bMultiple = 4
    else
        return
    end 
    self.tableParameter.bPlayerCount = 6

    --搓牌
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(6),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        self.tableParameter.bCuopai = 1
    else
        self.tableParameter.bCuopai = 0
    end
end

return RoomCreateLayer

