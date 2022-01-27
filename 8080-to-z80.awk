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

function imm8() {
    sub(/\s*,\s*</, ">>8")
    sub(/\s*,\s*>/, "\\&0FFH")
}

function gen(ptn, repl) {
    $0 = gensub(ptn, repl, 1)
}

function reg8() {
    sub(/\<M\>/, "(HL)")
}

function ldax() {
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

    if (length(pos) == 0) {
        print $0
    } else {
        tmp = sprintf("%*s" COMMENT_SEP " %s", CODE_START - CODE_END - 1, $0, pos)
        print tmp
    }
}


# Ignore 8080 comments
/^\s*\*/				{ if (!UNCLUTTERED) { print COMMENT_SEP " " $0 } next; }

# Remove comments from scanning
					{ $0 = cut($0) }

# META
/\<ORG\>/				{ gen(@/\<ORG\>\s+(\S+)/, "ORG \\1"); print_all(); next; }
/\<DS\>/				{ gen(@/\<DS\>\s+(\S+)/, "DS \\1"); print_all(); next; }
/\<DB\>/				{ gen(@/\<DB\>\s+(\S+)/, "DB \\1"); print_all(); next; }
/\<EQU\>/				{ gen(@/\<EQU\>\s+(\S+)/, "EQU \\1"); print_all(); next; }

# ADD
/\<ADD\>/				{ gen(@/\<ADD\>\s+(\S+)/, "ADD A,\\1"); reg8(); print_all(); next; }
/\<ADC\>/				{ gen(@/\<ADC\>\s+(\S+)/, "ADC A,\\1"); reg8(); print_all(); next; }
/\<ADI\>/ 				{ gen(@/\<ADI\>\s+(\S+)/, "ADD A,\\1"); imm8(); print_all(); next; }
/\<ACI\>/ 				{ gen(@/\<ACI\>\s+(\S+)/, "ADC \\1"); imm8(); print_all(); next; }
/\<DAD\>/                               { gen(@/\<DAD\>\s+(\S+)/, "ADD HL,\\1") }

# SUB
/\<SUB\>/ 				{ gen(@/\<SUB\>\s+(\S+)/, "SUB \\1"); reg8(); print_all(); next; }
/\<SUI\>/ 				{ gen(@/\<SUI\>\s+(\S+)/, "SUB \\1"); imm8(); print_all(); next; }
/\<SBB\>/				{ gen(@/\<SBB\>\s+(\S+)/, "SBC \\1"); reg8(); print_all(); next; }
/\<SBI\>/				{ gen(@/\<SBI\>\s+(\S+)/, "SBC \\1"); imm8(); print_all(); next; }

# INC
/\<INX\>/				{ gen(@/\<INX\>\s+(\S+)/, "INC \\1") }
/\<INR\>/ 				{ gen(@/\<INR\>\s+(\S+)/, "INC \\1"); reg8(); print_all(); next; }

# DEC
/\<DCR\>/				{ gen(@/\<DCR\>\s+(\S+)/, "DEC \\1"); reg8(); print_all(); next; }
/\<DCX\>/				{ gen(@/\<DCX\>\s+(\S+)/, "DEC \\1") }

# AND
/\<ANI\>/				{ gen(@/\<ANI\>\s+(\S+)/, "AND \\1"); imm8(); print_all(); next; }
/\<ANA\>/				{ gen(@/\<ANA\>\s+(\S+)/, "AND \\1"); reg8(); print_all(); next; }

# OR
/\<ORI\>/				{ gen(@/\<ORI\>\s+(\S+)/, "OR \\1"); imm8(); print_all(); next; }
/\<ORA\>/				{ gen(@/\<ORA\>\s+(\S+)/, "OR \\1"); reg8(); print_all(); next; }

# CP
/\<CPI\>/				{ gen(@/\<CPI\>\s+(\S+)/, "CP \\1"); imm8(); print_all(); next; }
/\<CMP\>/				{ gen(@/\<CMP\>\s+(\S+)/, "CP \\1"); reg8(); print_all(); next; }

# XOR
/\<XRI\>/				{ gen(@/\<XRI\>\s+(\S+)/, "XOR \\1"); imm8(); print_all(); next; }
/\<XRA\>/				{ gen(@/\<XRA\>\s+(\S+)/, "XOR \\1"); reg8(); print_all(); next; }

# JP
/\<JP\>/				{ gen(@/\<JP\>\s+(\S+)/, "JP P,\\1") }
/\<JMP\>/				{ gen(@/\<JMP\>\s+(\S+)/, "JP \\1") }
/\<JNZ\>/				{ gen(@/\<JNZ\>\s+(\S+)/, "JP NZ,\\1") }
/\<JZ\>/				{ gen(@/\<JZ\>\s+(\S+)/, "JP Z,\\1") }
/\<JNC\>/				{ gen(@/\<JNC\>\s+(\S+)/, "JP NC,\\1") }
/\<JC\>/				{ gen(@/\<JC\>\s+(\S+)/, "JP C,\\1") }
/\<JPO\>/				{ gen(@/\<JPO\>\s+(\S+)/, "JP O,\\1") }
/\<JPE\>/				{ gen(@/\<JPE\>\s+(\S+)/, "JP PE,\\1") }
/\<JM\>/				{ gen(@/\<JM\>\s+(\S+)/, "JP M,\\1") }
/\<PCHL\>/				{ gen(@/\<PCHL\>\s*(\S*)/, "JP (HL)") }

# CALL
/\<CALL\>/				{ gen(@/\<CALL\>\s+(\S+)/, "CALL \\1") }
/\<CNZ\>/				{ gen(@/\<CNZ\>\s+(\S+)/, "CALL NZ,\\1") }
/\<CZ\>/				{ gen(@/\<CZ\>\s+(\S+)/, "CALL Z,\\1") }
/\<CNC\>/				{ gen(@/\<CNC\>\s+(\S+)/, "CALL NC,\\1") }
/\<CC\>/				{ gen(@/\<CC\>\s+(\S+)/, "CALL C,\\1") }
/\<CPO\>/				{ gen(@/\<CPO\>\s+(\S+)/, "CALL O,\\1") }
/\<CPE\>/				{ gen(@/\<CPE\>\s+(\S+)/, "CALL PE,\\1") }
/\<CP\>/				{ gen(@/\<CP\>\s+(\S+)/, "CALL P,\\1") }
/\<CM\>/				{ gen(@/\<CM\>\s+(\S+)/, "CALL M,\\1") }

# RET
/\<RET\>/				{ gen(@/\<RET\>\s*(\S*)/, "RET") }
/\<RNZ\>/				{ gen(@/\<RNZ\>\s*(\S*)/, "RET NZ") }
/\<RZ\>/				{ gen(@/\<RZ\>\s*(\S*)/, "RET Z") }
/\<RNC\>/				{ gen(@/\<RNC\>\s*(\S*)/, "RET NC") }
/\<RC\>/				{ gen(@/\<RC\>\s*(\S*)/, "RET C") }
/\<RPO\>/				{ gen(@/\<RPO\>\s*(\S*)/, "RET O") }
/\<RPE\>/				{ gen(@/\<RPE\>\s*(\S*)/, "RET PE") }
/\<RP\>/				{ gen(@/\<RP\>\s*(\S*)/, "RET P") }
/\<RM\>/				{ gen(@/\<RM\>\s*(\S*)/, "RET M") }

# LD
/\<MOV\>/				{ gen(@/\<MOV\>\s+(\S+)\s*,\s*(\S+)/, "LD \\1,\\2"); reg8(); imm8(); print_all(); next; }
/\<MVI\>\s*\<M\>/			{ gen(@/\<MVI\>\s+\<M\>\s*/, "LD (HL)"); imm8(); }
/\<MVI\>/				{ gen(@/\<MVI\>\s+(\S+)\s*,\s*(\S+)/, "LD \\1,\\2"); imm8(); print_all(); next; }
/\<MOV\>/				{ gen(@/\<MOV\>\s+/, "LD ") }
/\<LXI\>/				{ gen(@/\<LXI\>\s+/, "LD ") }
/\<LHLD\>/				{ gen(@/\<LHLD\>\s*(\S+)/, "LD HL,(\\1)") }
/\<SHLD\>/				{ gen(@/\<SHLD\>\s+(\S+)/, "LD (\\1),HL") }
/\<SPHL\>/				{ gen(@/\<SPHL\>\s*(\S*)/, "LD SP,HL") }
/\<LDAX\>/				{ gen(@/\<LDAX\>\s*/, "LD A,"); ldax(); print_all(); next; }
/\<LDA\>/				{ gen(@/\<LDA\>\s*/, "LD A,") }
/\<STAX\>/				{ gen(@/\<STAX\>\s+(\S+)/, "LD \\1,A"); stax($0); print_all(); next; }
/\<STA\>/				{ gen(@/\<STA\>\s+(\S+)/, "LD (\\1),A"); print_all(); next; }

# EX
/\<XCHG\>/				{ gen(@/\<XCHG\>\s*(\S*)/, "EX DE,HL"); print_all(); next; }
/\<XTHL\>/				{ gen(@/\<XTHL\>\s*(\S*)/, "EX (SP),HL"); print_all(); next; }

# RST
/\<RST\>/				{ arg = get_arg(@/[0-7]/); gen(@/\<RST\>\s*([0-7])\>/, sprintf("RST %x", arg * 8)); print_all(); next; }

# IN
/\<IN\>/				{ gen(@/\<IN\>\s*(\S+)/, "IN A,\\1"); imm8(); print_all(); next; }

# OUT
/\<OUT\>/				{ gen(@/\<OUT\>\s*(\S+)/, "OUT (\\1),A"); imm8(); print_all(); next; }

# STACK
/\<PUSH\>/				{ gen(@/\<PUSH\>\s+/, "PUSH ") }
/\<POP\>/				{ gen(@/\<POP\>\s+/, "POP ") }

# Parameterless
/\<CMA\>/				{ gen(@/\<CMA\>\s*(\S*)/, "CPL") }
/\<STC\>/				{ gen(@/\<STC\>\s*(\S*)/, "SCF") }
/\<CMC\>/				{ gen(@/\<CMC\>\s*(\S*)/, "CCF") }
/\<RLC\>/				{ gen(@/\<RLC\>\s*(\S*)/, "RLCA") }
/\<RRC\>/				{ gen(@/\<RRC\>\s*(\S*)/, "RRCA") }
/\<RAL\>/				{ gen(@/\<RAL\>\s*(\S*)/, "RLA") }
/\<RAR\>/				{ gen(@/\<RAR\>\s*(\S*)/, "RRA") }

# Operators
/\<M\>/					{ sub(@/\<M\>/, "(HL)") }
/\<M\>/					{ sub(@/,\s*<M\>/, ",(HL)") }
/\<B\>/					{ sub(@/\<B\>/, "BC") }
/\<B\>/					{ sub(@/,\s*B\>/, ",BC") }
/\<D\>/					{ sub(@/\<D\>/, "DE") }
/\<D\>/					{ sub(@/,\s*D\>/, ",DE") }
/\<H\>/					{ sub(@/\<H\>/, "HL") }
/\<H\>/					{ sub(@/,\s*H\>/, ",HL") }
/\<PSW\>/				{ sub(@/\<PSW\>/,"AF") }
/\<PSW\>/				{ sub(@/,\s*PSW\>/,",AF") }
/,\s*</					{ sub(@/\s*,\s*</, ">>8") }
/,\s*>/					{ sub(@/\s*,\s*>/, "\\&0FFH") }

{ print_all() }
