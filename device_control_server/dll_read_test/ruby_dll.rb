# -*- coding: cp932 -*-
require 'fiddle/import'
require 'fiddle/types'

module WinAPI
    extend Fiddle::Importer
    dlload 'dlltest.dll'
    include Fiddle::BasicTypes
    include Fiddle::Win32Types
    extern "int hello()"
    extern "int hello2(char *)"
end

WinAPI::hello()
WinAPI::hello2("�\���\��") #.encode!('UTF-16LE'))
