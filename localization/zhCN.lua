
local L = tdCore:NewLocale(..., 'zhCN')

if not L then return end

L['<Left Click> '] = '<左键单击> '
L['<Right Click> '] = '<右键单击> '
L['<Alt-Right> '] = '<Alt-右键> '

L['Pack bags'] = '整理背包'
L['Show pack menu'] = '显示整理菜单'

L['Pack asc'] = '正序整理'
L['Pack desc'] = '逆序整理'
L['Save to bank'] = '保存到银行'
L['Load from bank'] = '从银行取出'
L['Open tdPack config frame']   = '打开tdPack设置界面'
L['Packing now'] = '正在整理'
L['Player in combat'] = '战斗中'
L['Please drop the item, money or skills.'] = '请放下鼠标上的物品、金钱或技能。'
L['Pack finish.'] = '整理完成'
L['Player enter combat, pack cancel.'] = '进入战斗，整理中止。'
L['Leave bank, pack cancel.'] = '离开银行，整理中止。'

L['Pack desc on default'] = '默认逆序整理'
L['Save to bank on default'] = '默认保存到银行'
L['Load to bag on default'] = '默认从银行取出'
L['Custom order'] = '自定义规则'
L['EquipLoc order'] = '装备位置规则'
L['Save to bank rule'] = '保存到银行规则'
L['Load from bank rule'] = '从银行取出规则'

L['Please input new rule:'] = '请输入新的规则：'

L['Show tdPack message'] = '显示整理信息'
L['Message frame'] = '信息窗口'
L['Show message in chat frame'] = '在聊天窗口显示信息'
L['Show message in error frame'] = '在错误窗口显示信息'

L['Import rules from other addon'] = '从其它插件导入规则'
L['Import rules from |cffffffff%s|r'] = '从 |cffffffff%s|r 导入规则'
L['%s not loaded.'] = '%s 没有载入'
L['Import %s rules will |cffff0000clear the current rules|r and |cffff0000reload addons|r, continue?'] = '导入%s规则将|cffff0000清空现有规则|r和|cffff0000重载插件|r，是否继续？'
