#!/usr/bin/awk -f

function getarg(ptn,    where) {
    where = match($0, ptn)
    if (where != 0) {
        return substr($0, where, RLENGTH)
    }
    return ""
}

function gen(ptn, repl) {
    $0 = gensub(ptn, repl, 1)
}

function reg8(p) {
    sub(/\<M\>/, "(HL)")
}

function ldax(p) {
    sub(/\<B\>/, "(BC)")
    sub(/\<D\>/, "(DE)")
}

function stax(p) {
    sub(/\<B\>/, "(BC)")
    sub(/\<D\>/, "(DE)")
}

# Remove comments
/^\*/					{ print $0; next; }

# ADD
/\<ADD\>/				{ gen(@/\<ADD\>(\s*)(\w+)/, "ADD\\1A,\\2"); reg8($0); print $0; next; }

# DEC
/\<DCR\>/				{ gen(@/\<DCR\>(\s*)(\w+)/, "DEC\\1\\2"); reg8($0); print $0; next; }
/\<DCX\>/				{ gen(@/\<DCX\>(\s*)(\w+)/, "DEC\\1\\2") }

# AND
/\<ANI\>/				{ gen(@/\<ANI\>(\s*)(\w+)/, "AND\\1\\2"); print $0; next; }
/\<ANA\>/				{ gen(@/\<ANA\>(\s*)(\w+)/, "AND\\1\\2"); reg8($0); print $0; next; }

# OR
/\<ORI\>/				{ gen(@/\<ORI\>(\s*)(\w+)/, "OR\\1\\2"); print $0; next; }
/\<ORA\>/				{ gen(@/\<ORA\>(\s*)(\w+)/, "OR\\1\\2"); reg8($0); print $0; next; }

# CP
/\<CPI\>/				{ gen(@/\<CPI\>(\s*)(\w+)/, "CP\\1\\2"); print $0; next; }
/\<CMP\>/				{ gen(@/\<CMP\>(\s*)(\w+)/, "CP\\1\\2"); reg8($0); print $0; next; }

# XOR
/\<XRI\>/				{ gen(@/\<XRI\>(\s*)(\w+)/, "XOR\\1\\2"); print $0; next; }
/\<XRA\>/				{ gen(@/\<XRA\>(\s*)(\w+)/, "XOR\\1\\2"); reg8($0); print $0; next; }

# JP
/\<(JMP)\>/				{ gen(@/\<JMP\>/, "JP") }
/\w:\s*\<(JMP)\>/			{ gen(@/\<JMP\>/, "JP") }
/\<JNZ\>/				{ gen(@/\<JNZ\>(\s*)(\w+)/, "JP NZ,\\1\\2") }
/\<JZ\>/				{ gen(@/\<JZ\>(\s*)(\w+)/, "JP Z,\\1\\2") }
/\<JNC\>/				{ gen(@/\<JNC\>(\s*)(\w+)/, "JP NC,\\1\\2") }
/\<JC\>/				{ gen(@/\<JNC\>(\s*)(\w+)/, "JP C,\\1\\2") }
/\<JPO\>/				{ gen(@/\<JPO\>(\s*)(\w+)/, "JP O,\\1\\2") }
/\<JPE\>/				{ gen(@/\<JPE\>(\s*)(\w+)/, "JP PE,\\1\\2") }
/\<JP\>/				{ gen(@/\<JP\>(\s*)(\w+)/, "JP P,\\1\\2") }
/\<JM\>/				{ gen(@/\<JM\>(\s*)(\w+)/, "JP M,\\1\\2") }
/\<PCHL\>/				{ gen(@/\<PCHL\>/, "JP (HL)") }

# CALL
/\<CNZ\>/				{ gen(@/\<CNZ\>(\s*)(\w+)/, "CALL"X"NZ,\\1\\2") }
/\<CZ\>/				{ gen(@/\<CZ\>(\s*)(\w+)/, "CALL"X"Z,\\1\\2") }
/\<CNC\>/				{ gen(@/\<CNC\>(\s*)(\w+)/, "CALL"X"NC,\\1\\2") }
/\<CC\>/				{ gen(@/\<CNC\>(\s*)(\w+)/, "CALL"X"C,\\1\\2") }
/\<CPO\>/				{ gen(@/\<CPO\>(\s*)(\w+)/, "CALL"X"O,\\1\\2") }
/\<CPE\>/				{ gen(@/\<CPE\>(\s*)(\w+)/, "CALL"X"PE,\\1\\2") }
/\<CP\>/				{ gen(@/\<CP\>(\s*)(\w+)/, "CALL"X"P,\\1\\2") }
/\<CM\>/				{ gen(@/\<CM\>(\s*)(\w+)/, "CALL"X"M,\\1\\2") }

# RET
/\<RNZ\>/				{ gen(@/\<RNZ\>(\s*)(\w+)/, "RET"X"NZ,\\1\\2") }
/\<RZ\>/				{ gen(@/\<RZ\>(\s*)(\w+)/, "RET"X"Z,\\1\\2") }
/\<RNC\>/				{ gen(@/\<RNC\>(\s*)(\w+)/, "RET"X"NC,\\1\\2") }
/\<RC\>/				{ gen(@/\<RNC\>(\s*)(\w+)/, "RET"X"C,\\1\\2") }
/\<RPO\>/				{ gen(@/\<RPO\>(\s*)(\w+)/, "RET"X"O,\\1\\2") }
/\<RPE\>/				{ gen(@/\<RPE\>(\s*)(\w+)/, "RET"X"PE,\\1\\2") }
/\<RP\>/				{ gen(@/\<RP\>(\s*)(\w+)/, "RET"X"P,\\1\\2") }
/\<RM\>/				{ gen(@/\<RM\>(\s*)(\w+)/, "RET"X"M,\\1\\2") }

# LD
/\<MOV\>\s*\w+\s*,\s*\<M\>/		{ gen(@/\<MOV\>(\s*)(\w+)(\s*,\s*)\<M\>/, "LD\\1\\2\\3(HL)"); print $0; next; }
/\<MOV\>/				{ gen(@/\<MOV\>(\s*)(\w+)(\s*,\s*)(\w+)/, "LD\\1\\2\\3\\4"); print $0; next; }
/\<MVI\>\s*\<M\>/			{ gen(@/\<MVI\>(\s*)\<M\>/, "LD\\1(HL)") }
/\<MVI\>/				{ gen(@/\<MVI\>(\s*)(\w+)(\s*,\s*)(\w+)/, "LD\\1\\2\\3\\4"); print $0; next; }
/\<MOV\>/				{ gen(@/MOV/, "LD") }
/\<LXI\>/				{ gen(@/\<LXI\>/, "LD") }
/\<LHLD\>/				{ gen(@/\<LHLD\>/, "LD"X"HL,") }
/\<SHLD\>/				{ gen(@/\<SHLD\>(\s*)(\w+)/, "LD\\1\\2,"X"HL") }
/\<SPHL\>/				{ gen(@/\<SPHL\>/, "LD"X"SP,") }
/\<LDAX\>/				{ gen(@/\<LDAX\>/, "LD"X"A,"); ldax($0); print $0; next; }
/\<LDA\>/				{ gen(@/\<LDA\>/, "LD"X"A,") }
/\<STAX\>/				{ gen(@/\<STAX\>(\s*)(\w+)/, "LD\\1\\2,"X"A"); stax($0); print $0; next; }
/\<STA\>/				{ gen(@/\<STA\>(\s*)(\w+)/, "LD\\1(\\2),"X"A"); print $0; next; }

# EX
/\<XCHG\>/				{ gen(@/\<XCHG\>/, "EX"X"DE,HL") }
/\<XTHL\>/				{ gen(@/\<XTHL\>/, "EX"X"(SP),HL") }

# RST
/\<RST\s*[0-7]\>/			{ arg = getarg(@/[0-7]/); gen(@/\<RST\>(\s*)([0-7])\>/, sprintf("RST\\1%x", arg * 8)); print $0; next; }

# IN
/\<IN\>/				{ gen(@/\<IN\>(\s*)(\w+)/, "IN\\1A,"X"\\2"); print $0; next; }

# OUT
/\<OUT\>/				{ gen(@/\<OUT\>(\s*)(\w+)/, "OUT\\1(\\2),"X"A"); print $0; next; }


# Operators
/\<M\>/					{ sub(@/\<A\>/, "(HL)", $2) }
/\<M\>/					{ sub(@/\<A\>/, "(HL)", $3) }
/\<B\>/					{ sub(@/\<B\>/, "BC", $2) }
/\<B\>/					{ sub(@/\<B\>/, "BC", $3) }
/\<D\>/					{ sub(@/\<D\>/, "DE", $2) }
/\<D\>/					{ sub(@/\<D\>/, "DE", $3) }
/\<H\>/					{ sub(@/\<H\>/, "HL", $2) }
/\<H\>/					{ sub(@/\<H\>/, "HL", $3) }
/\<PSW\>/				{ sub(@/\<PSW\>/, "AF", $2) }
/\<PSW\>/				{ sub(@/\<PSW\>/, "AF", $3) }

{ print $0 }
