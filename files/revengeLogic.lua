LUAGUI_NAME = "Revenge Value Indicator"
LUAGUI_AUTH = "TopazTK"
LUAGUI_DESC = "Adds a Revenge Value Indicator, bound to Scan!"

local _battleFlag = 0x24AA5B6

local _barPointer = 0x453DA2
local _msnPointer = 0x24A8AC2

local _valStartOffset = 0x4BBA4
local _barStartOffset = 0x4BBB8

local _barAddress = 0x00
local _msnAddress = 0x00

local _valueIncrementor = 0x00
local _valueIndicator = 0x00

local _slotAddress = 0x24BC4D2
local _slotModifier = 0x278

local _healthFound = false
local _barBossFound = false
local _barBosses = { "EH15", "HB32", "HE08", "MU09", "TR04"}

function _OnInit()
end

function _OnFrame()
    if _barAddress == 0 then
        _barAddress = ReadLong(_barPointer)
    end

    if ReadByte(_battleFlag) == 0x02 then

        for i = 0, 10 do
            if ReadInt(_slotAddress - (_slotModifier * i) + 0x04 ) >= 345 then
                _healthFound = true
                _msnAddress = ReadLong(_msnPointer)
            end
        end

        if _healthFound == true then
            _rvCurr = ReadFloat(ReadLong(0x56FD2A) + 0xD48, true)
            _rvMaxi = ReadFloat(ReadLong(0x56FD2A) + 0xD4C, true)

            _msnIdentifier = ReadString(_msnAddress + 0x14, 4, true)

            for i = 1, 5 do
                if _msnIdentifier == _barBosses[i] then
                    _barBossFound = true
                end
            end 

            if _barBossFound == true then
                WriteInt(_barAddress + _barStartOffset + 0x04, 0x1E, true)
                WriteInt(_barAddress + _barStartOffset + 0x0C, 0x46, true)

                WriteInt(_barAddress + _valStartOffset + 0x04, 0x24, true)
                WriteInt(_barAddress + _valStartOffset + 0x0C, 0x5D, true)
            else
                WriteInt(_barAddress + _barStartOffset + 0x04, 0xFFFFFFF3, true)
                WriteInt(_barAddress + _barStartOffset + 0x0C, 0x1B, true)

                WriteInt(_barAddress + _valStartOffset + 0x04, 0xFFFFFFF9, true)
                WriteInt(_barAddress + _valStartOffset + 0x0C, 0x32, true)
            end

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
        end

    else
        _healthFound = false
        _barBossFound = false
        _msnAddress = 0x00
        _valueIncrementor = 0x00
        _valueIndicator = 0x00
        WriteShort(_barAddress + _barStartOffset + 0x08, 0xFE04, true)
        WriteShort(_barAddress + _valStartOffset + 0x08, 0xFD94, true)
    end
end
