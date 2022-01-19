#!/usr/bin/awk -f

BEGIN {
    # external variables with defaults
    CODE_START   = CODE_START  ? CODE_START  :   1
    CODE_END     = CODE_END    ? CODE_END    :  -1
    COMMENT_SEP  = COMMENT_SEP ? COMMENT_SEP : ";"
    UNCLUTTERED  = UNCLUTTERED ? UNCLUTTERED :   0

    # used internally
    pre = ""; pos = ""; tmp = ""; cmt = ""
}

function cut(line,    n) {
    if (CODE_END > -1) {
        pre = substr(line, 1, CODE_START - 1)
        tmp = substr(line, CODE_START, CODE_END - CODE_START)
        pos = substr(line, CODE_END)
    } else {
        pre = substr(line, 1, CODE_START - 1)
        tmp = substr(line, CODE_START)
	pos = ""
    }
    n = index(tmp, COMMENT_SEP)
    if (n > 0) {
	cmt = substr(tmp, n)
        tmp = substr(tmp, 1, n - 1)
    } else {
	cmt = ""
    }
    return tmp
}

function get_arg(ptn,    where) {
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

function print_all() {
    if (UNCLUTTERED) {
        gsub(/\s*$/, "", $0)
        print $0
	return
    }

    $0 = sprintf("%s%s", $0, cmt)
    gsub(/\s*$/, "", $0)
    gsub(/\s*$/, "", pos)

    if (length(pre) + length($0) + length(pos) > 0) {
        tmp = sprintf("%s%*s%s", pre, CODE_START - CODE_END - 1, $0, pos)
	gsub(/\s*$/, tmp)
	print tmp
    } else {
        print ""
    }
}


# Ignore 8080 comments
/^\*/					{ if (!UNCLUTTERED) { print $0 } next; }

# Remove comments from scanning
					{ $0 = cut($0) }

# ADD
/\<ADD\>/				{ gen(@/\<ADD\>\s+(\S+)/, "ADD A,\\1"); reg8($0); print_all(); next; }
/\<ADC\>/				{ gen(@/\<ADC\>\s+(\S+)/, "ADC A,\\1"); reg8($0); print_all(); next; }
/\<ACI\>/ 				{ gen(@/\<ACI\>\s+(\S+)/, "ADC \\1"); print_all(); next; }
/\<DAD\>/                               { gen(@/\<ADD\>\s+(\S+)/, "ADD HL,\\1") }

# SUB
/\<SUB\>/ 				{ gen(@/\<SUB\>\s+(\S+)/, "SUB \\1"); reg8($0); print_all(); next; }
/\<SUI\>/ 				{ gen(@/\<SUI\>\s+(\S+)/, "SUB \\1"); print_all(); next; }
/\<SBB\>/				{ gen(@/\<SBB\>\s+(\S+)/, "SBC \\1"); reg8($0); print_all(); next; }
/\<SBI\>/				{ gen(@/\<SBI\>\s+(\S+)/, "SBC \\1"); print_all(); next; }

# INC
/\<INX\>/				{ gen(@/\<INX\>\s+(\S+)/, "INC \\1") }
/\<INR\>/ 				{ gen(@/\<INR\>\s+(\S+)/, "INC \\1"); reg8($0); print_all(); next; }

# DEC
/\<DCR\>/				{ gen(@/\<DCR\>\s+(\S+)/, "DEC \\1"); reg8($0); print_all(); next; }
/\<DCX\>/				{ gen(@/\<DCX\>\s+(\S+)/, "DEC \\1") }

# AND
/\<ANI\>/				{ gen(@/\<ANI\>\s+(\S+)/, "AND \\1"); print_all(); next; }
/\<ANA\>/				{ gen(@/\<ANA\>\s+(\S+)/, "AND \\1"); reg8($0); print_all(); next; }

# OR
/\<ORI\>/				{ gen(@/\<ORI\>\s+(\S+)/, "OR \\1"); print_all(); next; }
/\<ORA\>/				{ gen(@/\<ORA\>\s+(\S+)/, "OR \\1"); reg8($0); print_all(); next; }

# CP
/\<CPI\>/				{ gen(@/\<CPI\>\s+(\S+)/, "CP \\1"); print_all(); next; }
/\<CMP\>/				{ gen(@/\<CMP\>\s+(\S+)/, "CP \\1"); reg8($0); print_all(); next; }

# XOR
/\<XRI\>/				{ gen(@/\<XRI\>\s+(\S+)/, "XOR \\1"); print_all(); next; }
/\<XRA\>/				{ gen(@/\<XRA\>\s+(\S+)/, "XOR \\1"); reg8($0); print_all(); next; }

# JP
/\<JP\>/				{ gen(@/\<JP\>\s+(\S+)/, "JP P,\\1") }
/\<(JMP)\>/				{ gen(@/\<JMP\>/, "JP") }
/\<JNZ\>/				{ gen(@/\<JNZ\>\s+(\S+)/, "JP NZ,\\1") }
/\<JZ\>/				{ gen(@/\<JZ\>\s+(\S+)/, "JP Z,\\1") }
/\<JNC\>/				{ gen(@/\<JNC\>\s+(\S+)/, "JP NC,\\1") }
/\<JC\>/				{ gen(@/\<JNC\>\s+(\S+)/, "JP C,\\1") }
/\<JPO\>/				{ gen(@/\<JPO\>\s+(\S+)/, "JP O,\\1") }
/\<JPE\>/				{ gen(@/\<JPE\>\s+(\S+)/, "JP PE,\\1") }
/\<JM\>/				{ gen(@/\<JM\>\s+(\S+)/, "JP M,\\1") }
/\<PCHL\>/				{ gen(@/\<PCHL\>/, "JP (HL)") }

# CALL
/\<CNZ\>/				{ gen(@/\<CNZ\>\s+(\S+)/, "CALL NZ,\\1") }
/\<CZ\>/				{ gen(@/\<CZ\>\s+(\S+)/, "CALL Z,\\1") }
/\<CNC\>/				{ gen(@/\<CNC\>\s+(\S+)/, "CALL NC,\\1") }
/\<CC\>/				{ gen(@/\<CNC\>\s+(\S+)/, "CALL C,\\1") }
/\<CPO\>/				{ gen(@/\<CPO\>\s+(\S+)/, "CALL O,\\1") }
/\<CPE\>/				{ gen(@/\<CPE\>\s+(\S+)/, "CALL PE,\\1") }
/\<CP\>/				{ gen(@/\<CP\>\s+(\S+)/, "CALL P,\\1") }
/\<CM\>/				{ gen(@/\<CM\>\s+(\S+)/, "CALL M,\\1") }

# RET
/\<RNZ\>/				{ gen(@/\<RNZ\>\s+(\S+)/, "RET NZ,\\1") }
/\<RZ\>/				{ gen(@/\<RZ\>\s+(\S+)/, "RET Z,\\1") }
/\<RNC\>/				{ gen(@/\<RNC\>\s+(\S+)/, "RET NC,\\1") }
/\<RC\>/				{ gen(@/\<RNC\>\s+(\S+)/, "RET C,\\1") }
/\<RPO\>/				{ gen(@/\<RPO\>\s+(\S+)/, "RET O,\\1") }
/\<RPE\>/				{ gen(@/\<RPE\>\s+(\S+)/, "RET PE,\\1") }
/\<RP\>/				{ gen(@/\<RP\>\s+(\S+)/, "RET P,\\1") }
/\<RM\>/				{ gen(@/\<RM\>\s+(\S+)/, "RET M,\\1") }

# LD
/\<MOV\>\s*\S+\s*,\s*\<M\>/		{ gen(@/\<MOV\>\s+(\S+)\s*,\s*\<M\>/, "LD \\1,(HL)"); print_all(); next; }
/\<MOV\>/				{ gen(@/\<MOV\>\s+(\S+)\s*,\s*(\S+)/, "LD \\1,\\2"); print_all(); next; }
/\<MVI\>\s*\<M\>/			{ gen(@/\<MVI\>\s+\<M\>/, "LD (HL)") }
/\<MVI\>/				{ gen(@/\<MVI\>\s+(\S+)\s*,\s*(\S+)/, "LD \\1,\\2"); print_all(); next; }
/\<MOV\>/				{ gen(@/\<MOV\>\s+/, "LD ") }
/\<LXI\>/				{ gen(@/\<LXI\>\s+/, "LD ") }
/\<LHLD\>/				{ gen(@/\<LHLD\>\s*/, "LD HL,") }
/\<SHLD\>/				{ gen(@/\<SHLD\>\s+(\S+)/, "LD \\1,HL") }
/\<SPHL\>/				{ gen(@/\<SPHL\>\s*/, "LD SP,") }
/\<LDAX\>/				{ gen(@/\<LDAX\>\s*/, "LD A,"); ldax($0); print_all(); next; }
/\<LDA\>/				{ gen(@/\<LDA\>\s*/, "LD A,") }
/\<STAX\>/				{ gen(@/\<STAX\>\s+(\S+)/, "LD \\1,A"); stax($0); print_all(); next; }
/\<STA\>/				{ gen(@/\<STA\>\s+(\S+)/, "LD (\\1),A"); print_all(); next; }

# EX
/\<XCHG\>/				{ gen(@/\<XCHG\>\s*,?/, "EX DE,HL"); print_all(); next; }
/\<XTHL\>/				{ gen(@/\<XTHL\>\s*,?/, "EX (SP),HL"); print_all(); next; }

# RST
/\<RST\>/				{ arg = get_arg(@/[0-7]/); gen(@/\<RST\>\s*([0-7])\>/, sprintf("RST %x", arg * 8)); print_all(); next; }

# IN
/\<IN\>/				{ gen(@/\<IN\>\s*(\S+)/, "IN A,\\1"); print_all(); next; }

# OUT
/\<OUT\>/				{ gen(@/\<OUT\>\s*(\S+)/, "OUT (\\1),A"); print_all(); next; }

# POP
/\<POP\>/				{ gen(@/\<POP\>\s+/, "POP ") }

# Parameterless
/\<CMA\>/				{ gen(@/\<CMA\>\s+/, "CPL") }
/\<STC\>/				{ gen(@/\<STC\>\s+/, "SCF") }
/\<CMC\>/				{ gen(@/\<CMC\>\s+/, "CCF") }
/\<RLC\>/				{ gen(@/\<RLC\>\s+/, "RLCA") }
/\<RRC\>/				{ gen(@/\<RRC\>\s+/, "RRCA") }
/\<RAL\>/				{ gen(@/\<RAL\>\s+/, "RLA") }
/\<RAR\>/				{ gen(@/\<RAR\>\s+/, "RRA") }

# Operators
/\<M\>/					{ sub(@/\<A\>/, "(HL)") }
/\<M\>/					{ sub(@/,\s*<A\>/, ",(HL)") }
/\<B\>/					{ sub(@/\<B\>/, "BC") }
/\<B\>/					{ sub(@/,\s*B\>/, ",BC") }
/\<D\>/					{ sub(@/\<D\>/, "DE") }
/\<D\>/					{ sub(@/,\s*D\>/, ",DE") }
/\<H\>/					{ sub(@/\<H\>/, "HL") }
/\<H\>/					{ sub(@/,\s*H\>/, ",HL") }
/\<PSW\>/				{ sub(@/\<PSW\>/,"AF") }
/\<PSW\>/				{ sub(@/,\s*PSW\>/,",AF") }

{ print_all() }
