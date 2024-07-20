local StrToNumber = tonumber;
local Byte = string.byte;
local Char = string.char;
local Sub = string.sub;
local Subg = string.gsub;
local Rep = string.rep;
local Concat = table.concat;
local Insert = table.insert;
local LDExp = math.ldexp;
local GetFEnv = getfenv or function()
	return _ENV;
end;
local Setmetatable = setmetatable;
local PCall = pcall;
local Select = select;
local Unpack = unpack or table.unpack;
local ToNumber = tonumber;
local function VMCall(ByteString, vmenv, ...)
	local DIP = 1;
	local repeatNext;
	ByteString = Subg(Sub(ByteString, 5), "..", function(byte)
		if (Byte(byte, 2) == 79) then
			local FlatIdent_95CAC = 0;
			while true do
				if (FlatIdent_95CAC == 0) then
					repeatNext = StrToNumber(Sub(byte, 1, 1));
					return "";
				end
			end
		else
			local a = Char(StrToNumber(byte, 16));
			if repeatNext then
				local FlatIdent_8B336 = 0;
				local b;
				while true do
					if (FlatIdent_8B336 == 1) then
						return b;
					end
					if (FlatIdent_8B336 == 0) then
						b = Rep(a, repeatNext);
						repeatNext = nil;
						FlatIdent_8B336 = 1;
					end
				end
			else
				return a;
			end
		end
	end);
	local function gBit(Bit, Start, End)
		if End then
			local FlatIdent_76979 = 0;
			local Res;
			while true do
				if (FlatIdent_76979 == 0) then
					Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
					return Res - (Res % 1);
				end
			end
		else
			local Plc = 2 ^ (Start - 1);
			return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
		end
	end
	local function gBits8()
		local FlatIdent_69270 = 0;
		local a;
		while true do
			if (FlatIdent_69270 == 1) then
				return a;
			end
			if (FlatIdent_69270 == 0) then
				a = Byte(ByteString, DIP, DIP);
				DIP = DIP + 1;
				FlatIdent_69270 = 1;
			end
		end
	end
	local function gBits16()
		local FlatIdent_21DDC = 0;
		local a;
		local b;
		while true do
			if (FlatIdent_21DDC == 1) then
				return (b * 256) + a;
			end
			if (FlatIdent_21DDC == 0) then
				a, b = Byte(ByteString, DIP, DIP + 2);
				DIP = DIP + 2;
				FlatIdent_21DDC = 1;
			end
		end
	end
	local function gBits32()
		local FlatIdent_7126A = 0;
		local a;
		local b;
		local c;
		local d;
		while true do
			if (FlatIdent_7126A == 1) then
				return (d * 16777216) + (c * 65536) + (b * 256) + a;
			end
			if (FlatIdent_7126A == 0) then
				a, b, c, d = Byte(ByteString, DIP, DIP + 3);
				DIP = DIP + 4;
				FlatIdent_7126A = 1;
			end
		end
	end
	local function gFloat()
		local FlatIdent_2661B = 0;
		local Left;
		local Right;
		local IsNormal;
		local Mantissa;
		local Exponent;
		local Sign;
		while true do
			if (FlatIdent_2661B == 1) then
				IsNormal = 1;
				Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
				FlatIdent_2661B = 2;
			end
			if (FlatIdent_2661B == 2) then
				Exponent = gBit(Right, 21, 31);
				Sign = ((gBit(Right, 32) == 1) and -1) or 1;
				FlatIdent_2661B = 3;
			end
			if (FlatIdent_2661B == 0) then
				Left = gBits32();
				Right = gBits32();
				FlatIdent_2661B = 1;
			end
			if (FlatIdent_2661B == 3) then
				if (Exponent == 0) then
					if (Mantissa == 0) then
						return Sign * 0;
					else
						local FlatIdent_67691 = 0;
						while true do
							if (FlatIdent_67691 == 0) then
								Exponent = 1;
								IsNormal = 0;
								break;
							end
						end
					end
				elseif (Exponent == 2047) then
					return ((Mantissa == 0) and (Sign * (1 / 0))) or (Sign * NaN);
				end
				return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
			end
		end
	end
	local function gString(Len)
		local Str;
		if not Len then
			local FlatIdent_39B0 = 0;
			while true do
				if (FlatIdent_39B0 == 0) then
					Len = gBits32();
					if (Len == 0) then
						return "";
					end
					break;
				end
			end
		end
		Str = Sub(ByteString, DIP, (DIP + Len) - 1);
		DIP = DIP + Len;
		local FStr = {};
		for Idx = 1, #Str do
			FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
		end
		return Concat(FStr);
	end
	local gInt = gBits32;
	local function _R(...)
		return {...}, Select("#", ...);
	end
	local function Deserialize()
		local FlatIdent_1076E = 0;
		local Instrs;
		local Functions;
		local Lines;
		local Chunk;
		local ConstCount;
		local Consts;
		while true do
			if (2 == FlatIdent_1076E) then
				for Idx = 1, gBits32() do
					local Descriptor = gBits8();
					if (gBit(Descriptor, 1, 1) == 0) then
						local Type = gBit(Descriptor, 2, 3);
						local Mask = gBit(Descriptor, 4, 6);
						local Inst = {gBits16(),gBits16(),nil,nil};
						if (Type == 0) then
							local FlatIdent_2E34E = 0;
							while true do
								if (FlatIdent_2E34E == 0) then
									Inst[3] = gBits16();
									Inst[4] = gBits16();
									break;
								end
							end
						elseif (Type == 1) then
							Inst[3] = gBits32();
						elseif (Type == 2) then
							Inst[3] = gBits32() - (2 ^ 16);
						elseif (Type == 3) then
							Inst[3] = gBits32() - (2 ^ 16);
							Inst[4] = gBits16();
						end
						if (gBit(Mask, 1, 1) == 1) then
							Inst[2] = Consts[Inst[2]];
						end
						if (gBit(Mask, 2, 2) == 1) then
							Inst[3] = Consts[Inst[3]];
						end
						if (gBit(Mask, 3, 3) == 1) then
							Inst[4] = Consts[Inst[4]];
						end
						Instrs[Idx] = Inst;
					end
				end
				for Idx = 1, gBits32() do
					Functions[Idx - 1] = Deserialize();
				end
				return Chunk;
			end
			if (1 == FlatIdent_1076E) then
				ConstCount = gBits32();
				Consts = {};
				for Idx = 1, ConstCount do
					local FlatIdent_7F35E = 0;
					local Type;
					local Cons;
					while true do
						if (1 == FlatIdent_7F35E) then
							if (Type == 1) then
								Cons = gBits8() ~= 0;
							elseif (Type == 2) then
								Cons = gFloat();
							elseif (Type == 3) then
								Cons = gString();
							end
							Consts[Idx] = Cons;
							break;
						end
						if (FlatIdent_7F35E == 0) then
							Type = gBits8();
							Cons = nil;
							FlatIdent_7F35E = 1;
						end
					end
				end
				Chunk[3] = gBits8();
				FlatIdent_1076E = 2;
			end
			if (FlatIdent_1076E == 0) then
				Instrs = {};
				Functions = {};
				Lines = {};
				Chunk = {Instrs,Functions,nil,Lines};
				FlatIdent_1076E = 1;
			end
		end
	end
	local function Wrap(Chunk, Upvalues, Env)
		local Instr = Chunk[1];
		local Proto = Chunk[2];
		local Params = Chunk[3];
		return function(...)
			local Instr = Instr;
			local Proto = Proto;
			local Params = Params;
			local _R = _R;
			local VIP = 1;
			local Top = -1;
			local Vararg = {};
			local Args = {...};
			local PCount = Select("#", ...) - 1;
			local Lupvals = {};
			local Stk = {};
			for Idx = 0, PCount do
				if (Idx >= Params) then
					Vararg[Idx - Params] = Args[Idx + 1];
				else
					Stk[Idx] = Args[Idx + 1];
				end
			end
			local Varargsz = (PCount - Params) + 1;
			local Inst;
			local Enum;
			while true do
				Inst = Instr[VIP];
				Enum = Inst[1];
				if (Enum <= 13) then
					if (Enum <= 6) then
						if (Enum <= 2) then
							if (Enum <= 0) then
								do
									return;
								end
							elseif (Enum > 1) then
								Stk[Inst[2]] = {};
							elseif Stk[Inst[2]] then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum <= 4) then
							if (Enum > 3) then
								local FlatIdent_2FD19 = 0;
								local Edx;
								local Results;
								local Limit;
								local B;
								local A;
								while true do
									if (FlatIdent_2FD19 == 5) then
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_2FD19 = 6;
									end
									if (FlatIdent_2FD19 == 0) then
										Edx = nil;
										Results, Limit = nil;
										B = nil;
										A = nil;
										Stk[Inst[2]] = Upvalues[Inst[3]];
										FlatIdent_2FD19 = 1;
									end
									if (FlatIdent_2FD19 == 9) then
										Top = (Limit + A) - 1;
										Edx = 0;
										for Idx = A, Top do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_2FD19 = 10;
									end
									if (FlatIdent_2FD19 == 8) then
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results, Limit = _R(Stk[A](Stk[A + 1]));
										FlatIdent_2FD19 = 9;
									end
									if (FlatIdent_2FD19 == 6) then
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										FlatIdent_2FD19 = 7;
									end
									if (FlatIdent_2FD19 == 4) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_2FD19 = 5;
									end
									if (FlatIdent_2FD19 == 1) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_2FD19 = 2;
									end
									if (FlatIdent_2FD19 == 2) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										FlatIdent_2FD19 = 3;
									end
									if (FlatIdent_2FD19 == 3) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										FlatIdent_2FD19 = 4;
									end
									if (FlatIdent_2FD19 == 10) then
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Top));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										break;
									end
									if (FlatIdent_2FD19 == 7) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_2FD19 = 8;
									end
								end
							else
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							end
						elseif (Enum > 5) then
							Stk[Inst[2]]();
						else
							local FlatIdent_817B0 = 0;
							local A;
							while true do
								if (FlatIdent_817B0 == 0) then
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									break;
								end
							end
						end
					elseif (Enum <= 9) then
						if (Enum <= 7) then
							local A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
						elseif (Enum > 8) then
							Stk[Inst[2]] = Stk[Inst[3]];
						else
							local A = Inst[2];
							Stk[A](Unpack(Stk, A + 1, Inst[3]));
						end
					elseif (Enum <= 11) then
						if (Enum == 10) then
							local A = Inst[2];
							local Results, Limit = _R(Stk[A](Stk[A + 1]));
							Top = (Limit + A) - 1;
							local Edx = 0;
							for Idx = A, Top do
								Edx = Edx + 1;
								Stk[Idx] = Results[Edx];
							end
						elseif (Inst[2] == Stk[Inst[4]]) then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
					elseif (Enum > 12) then
						local NewProto = Proto[Inst[3]];
						local NewUvals;
						local Indexes = {};
						NewUvals = Setmetatable({}, {__index=function(_, Key)
							local FlatIdent_91B54 = 0;
							local Val;
							while true do
								if (FlatIdent_91B54 == 0) then
									Val = Indexes[Key];
									return Val[1][Val[2]];
								end
							end
						end,__newindex=function(_, Key, Value)
							local FlatIdent_6679B = 0;
							local Val;
							while true do
								if (FlatIdent_6679B == 0) then
									Val = Indexes[Key];
									Val[1][Val[2]] = Value;
									break;
								end
							end
						end});
						for Idx = 1, Inst[4] do
							VIP = VIP + 1;
							local Mvm = Instr[VIP];
							if (Mvm[1] == 9) then
								Indexes[Idx - 1] = {Stk,Mvm[3]};
							else
								Indexes[Idx - 1] = {Upvalues,Mvm[3]};
							end
							Lupvals[#Lupvals + 1] = Indexes;
						end
						Stk[Inst[2]] = Wrap(NewProto, NewUvals, Env);
					elseif (Stk[Inst[2]] == Stk[Inst[4]]) then
						VIP = VIP + 1;
					else
						VIP = Inst[3];
					end
				elseif (Enum <= 20) then
					if (Enum <= 16) then
						if (Enum <= 14) then
							Stk[Inst[2]][Inst[3]] = Inst[4];
						elseif (Enum == 15) then
							VIP = Inst[3];
						else
							Stk[Inst[2]] = Upvalues[Inst[3]];
						end
					elseif (Enum <= 18) then
						if (Enum == 17) then
							Env[Inst[3]] = Stk[Inst[2]];
						else
							Stk[Inst[2]] = Inst[3];
						end
					elseif (Enum == 19) then
						if (Stk[Inst[2]] == Inst[4]) then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
					else
						local FlatIdent_52551 = 0;
						local A;
						while true do
							if (FlatIdent_52551 == 0) then
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Top));
								break;
							end
						end
					end
				elseif (Enum <= 23) then
					if (Enum <= 21) then
						Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
					elseif (Enum > 22) then
						local A = Inst[2];
						local B = Stk[Inst[3]];
						Stk[A + 1] = B;
						Stk[A] = B[Inst[4]];
					else
						Stk[Inst[2]] = Inst[3] ~= 0;
					end
				elseif (Enum <= 25) then
					if (Enum > 24) then
						local A = Inst[2];
						local Cls = {};
						for Idx = 1, #Lupvals do
							local FlatIdent_869A9 = 0;
							local List;
							while true do
								if (FlatIdent_869A9 == 0) then
									List = Lupvals[Idx];
									for Idz = 0, #List do
										local FlatIdent_276C2 = 0;
										local Upv;
										local NStk;
										local DIP;
										while true do
											if (FlatIdent_276C2 == 1) then
												DIP = Upv[2];
												if ((NStk == Stk) and (DIP >= A)) then
													Cls[DIP] = NStk[DIP];
													Upv[1] = Cls;
												end
												break;
											end
											if (FlatIdent_276C2 == 0) then
												Upv = List[Idz];
												NStk = Upv[1];
												FlatIdent_276C2 = 1;
											end
										end
									end
									break;
								end
							end
						end
					else
						local FlatIdent_287B5 = 0;
						local B;
						local A;
						while true do
							if (3 == FlatIdent_287B5) then
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								FlatIdent_287B5 = 4;
							end
							if (FlatIdent_287B5 == 0) then
								B = nil;
								A = nil;
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								FlatIdent_287B5 = 1;
							end
							if (6 == FlatIdent_287B5) then
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								FlatIdent_287B5 = 7;
							end
							if (FlatIdent_287B5 == 1) then
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_287B5 = 2;
							end
							if (2 == FlatIdent_287B5) then
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_287B5 = 3;
							end
							if (FlatIdent_287B5 == 5) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_287B5 = 6;
							end
							if (FlatIdent_287B5 == 4) then
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								FlatIdent_287B5 = 5;
							end
							if (FlatIdent_287B5 == 7) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								break;
							end
						end
					end
				elseif (Enum > 26) then
					for Idx = Inst[2], Inst[3] do
						Stk[Idx] = nil;
					end
				else
					Stk[Inst[2]] = Env[Inst[3]];
				end
				VIP = VIP + 1;
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!0C3O00028O00027O0040026O00F03F03043O0067616D65030A3O004765745365727669636503103O0055736572496E7075745365727669636503113O005265706C69636174656453746F7261676503073O00506C6179657273030B3O004C6F63616C506C6179657203053O005265736574030A3O00496E707574426567616E03073O00436F2O6E656374003B3O002O123O00014O001B000100053O0026133O002F0001000200040F3O002F00012O001B000500053O0026130001001A0001000100040F3O001A0001002O12000600013O000E0B0003000C0001000600040F3O000C0001002O12000100033O00040F3O001A0001002613000600080001000100040F3O0008000100121A000700043O00201800070007000500122O000900066O0007000900024O000200073O00122O000700043O00202O00070007000500122O000900076O0007000900024O000300073O00122O000600033O00040F3O00080001002613000100210001000300040F3O0021000100121A000600043O0020030006000600080020030004000600092O0016000500013O002O12000100023O002613000100050001000200040F3O0005000100060D00063O000100022O00093O00044O00093O00033O0012110006000A3O00200300060002000B00201700060006000C00060D00080001000100012O00093O00054O000800060008000100040F3O0039000100040F3O0005000100040F3O003900010026133O00340001000100040F3O00340001002O12000100014O001B000200023O002O123O00033O0026133O00020001000300040F3O000200012O001B000300043O002O123O00023O00040F3O000200012O00199O003O00013O00023O000C3O00028O00026O00F03F03083O004261636B7061636B03043O0050697065026O0008402O01026O00104003063O00546F75636831030A3O004669726553657276657203063O00756E7061636B03093O00436861726163746572030B3O00427265616B4A6F696E7473002E3O002O123O00014O001B000100023O0026133O00070001000100040F3O00070001002O12000100014O001B000200023O002O123O00023O0026133O00020001000200040F3O00020001002613000100230001000100040F3O00230001002O12000300013O0026130003001E0001000100040F3O001E00012O000200043O00032O000400055O00202O00050005000300202O00050005000400102O00040002000500302O00040005000600302O0004000700064O000200046O000400013O00202O00040004000800202O00040004000900122O0006000A6O000700026O000600076O00043O000100122O000300023O0026130003000C0001000200040F3O000C0001002O12000100023O00040F3O0023000100040F3O000C0001002613000100090001000200040F3O000900012O001000035O00200300030003000B00201700030003000C2O000500030002000100040F3O002D000100040F3O0009000100040F3O002D000100040F3O000200016O00017O00053O00028O0003073O004B6579436F646503043O00456E756D03013O005203053O00526573657402143O002O12000200013O002613000200010001000100040F3O000100010006010001000600013O00040F3O000600016O00013O00200300033O000200121A000400033O00200300040004000200200300040004000400060C000300130001000400040F3O001300012O001000035O0006010003001300013O00040F3O0013000100121A000300054O000600030001000100040F3O0013000100040F3O000100016O00017O00", GetFEnv(), ...);
