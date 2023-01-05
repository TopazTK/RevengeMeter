LUAGUI_NAME = "Revenge Value Indicator"
LUAGUI_AUTH = "TopazTK"
LUAGUI_DESC = "Adds a Revenge Value Indicator, bound to Scan!"

local _battleFlag = 0x24AA5B6

local _barPointer = 0x453DA2

local _valStartOffset = 0x4BBA4
local _barStartOffset = 0x4BBB8

local _barAddress = 0x00

local _valueIncrementor = 0x00
local _valueIndicator = 0x00

function _OnInit()
end

function _OnFrame()
    if _barAddress == 0 then
        _barAddress = ReadLong(_barPointer)
    end

    if ReadByte(_battleFlag) == 0x02 then
        _rvCurr = ReadFloat(ReadLong(0x56FD2A) + 0xD48, true)
        _rvMaxi = ReadFloat(ReadLong(0x56FD2A) + 0xD4C, true)

        WriteShort(_barAddress + _barStartOffset + 0x08, 0xFD6F, true)

        if _rvMaxi < 0xFF and _rvMaxi > 0x00 then
            if _valueIncrementor == 0x00 then
                _valueIncrementor = 0x6B / _rvMaxi;
            end
        
            _valueIndicator = math.floor(_valueIncrementor * _rvCurr)

            if _rvCurr > _rvMaxi then
                WriteShort(_barAddress + _valStartOffset + 0x08, 0xFDFF, true)
            else
                WriteShort(_barAddress + _valStartOffset + 0x08, 0xFD94 + _valueIndicator, true)
            end
        else
            WriteShort(_barAddress + _valStartOffset + 0x08, 0xFD94, true)
        end

    else
        _valueIncrementor = 0x00
        _valueIndicator = 0x00
        WriteShort(_barAddress + _barStartOffset + 0x08, 0xFE04, true)
        WriteShort(_barAddress + _valStartOffset + 0x08, 0xFD94, true)
    end
end
