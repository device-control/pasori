# -*- coding: cp932 -*-
require 'ffi'

module WinAPI
  extend FFI::Library
  ffi_lib "dlltest.dll"
  attach_function :hello, [], :int
  attach_function :hello2, [:string], :int
end

WinAPI::hello()
WinAPI::hello2("表示能力") #.encode!('UTF-16LE'))
