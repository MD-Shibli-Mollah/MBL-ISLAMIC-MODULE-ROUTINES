* @ValidationCode : MjotMTI3MjkzODExNjpDcDEyNTI6MTU5MzU4MjMwMTcwNzpEZWxsOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 01 Jul 2020 11:45:01
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : Dell
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE CM.MBL.CONVT.AMT.WORD
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $USING FT.Contract
    $USING EB.SystemTables
    $USING EB.Reports
    $USING EB.Foundation
    $USING TT.Contract
*-----------------------------------------------------------------------------
* This Routine Convert number to Text. This routine call CM.CALHUND Routine.
* Return value : "LNGVAR" is incoming parameter, and "TXTOUT" is outgoing paramete.
* Developed By : Md Rayhan Uddin

    AppName = EB.SystemTables.getApplication()
    IF AppName EQ 'FUNDS.TRANSFER' THEN
        LNGVAR = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAmount)
        IF LNGVAR EQ "" OR LNGVAR EQ 0 THEN
            LNGVAR = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditAmount)
        END
    END
    
    IF AppName EQ 'TELLER' THEN
        LNGVAR = EB.SystemTables.getRNew(TT.Contract.Teller.TeAmountLocalOne)
    END
    
    TXTOUT = ''
    TXTVAR1=''
    INTVAL=''
    Y.COMI.LEN = LEN(LNGVAR)
    IF Y.COMI.LEN LT 20 THEN
        
        INTVAL = FIELD(LNGVAR,'.',1)
        INTVAL3 = FIELD(LNGVAR,'.',2)

        IF INTVAL3 NE 0 THEN
            INTVAL2=INTVAL3
        END ELSE
            INTVAL2=0
        END

        CORE=INT(INTVAL / 10000000)
        CALL CM.CALHUND(CORE,INTCORE)
        INTVAL = INT(INTVAL - INT(INTVAL / 10000000) * 10000000)

        LAC=INT(INTVAL / 100000)
        CALL CM.CALHUND(LAC,INTLAC)
        INTVAL = INT(INTVAL - INT(INTVAL / 100000) * 100000)

        THOUSAND=INT(INTVAL / 1000)
        CALL CM.CALHUND(THOUSAND,INTTHOUSAND)
        INTVAL = INT(INTVAL - INT(INTVAL / 1000) * 1000)

        HUNDRED=INT(INTVAL / 100)
        CALL CM.CALHUND(HUNDRED,INTHUNDRED)
        INTVAL = INT(INTVAL - INT(INTVAL / 100) * 100)

        REST=INT(INTVAL / 1)
        CALL CM.CALHUND(REST,INTREST)

        DES=INT(INTVAL2 / 1)
        CALL CM.CALHUND(DES,INTDES)

        IF LEN(INTCORE) EQ 0 THEN
            TXTVAR1=INTCORE:" ":""
        END ELSE
            TXTVAR1=INTCORE:" ":"Core"
        END

        IF LEN(INTLAC) EQ 0 THEN
            TXTVAR1=TXTVAR1:" ":INTLAC:"":""
        END ELSE
            TXTVAR1=TXTVAR1:" ":INTLAC:" ":"Lac"
        END

        IF LEN(INTTHOUSAND) EQ 0 THEN
            TXTVAR1=TXTVAR1:" ":INTTHOUSAND:"":""
        END ELSE
            TXTVAR1=TXTVAR1:" ":INTTHOUSAND:" ":"Thousand"
        END

        IF LEN(INTHUNDRED) EQ 0 THEN
            TXTVAR1=TXTVAR1:" ":INTHUNDRED:"":""
        END ELSE
            TXTVAR1=TXTVAR1:" ":INTHUNDRED:" ":"Hundred"
        END

        TXTVAR1=TXTVAR1:" ":INTREST:" ":"Taka"

        IF LEN(INTDES) EQ 0 THEN
*TXTVAR1=TXTVAR1:""
        END ELSE
            TXTVAR1=TXTVAR1:" ":"and":" ":INTDES:" ":"Paisa"
        END
        TXTOUT = TXTVAR1
        IF AppName EQ 'FUNDS.TRANSFER' THEN
            APPLICATION.NAMES = 'FUNDS.TRANSFER'
            LOCAL.FIELDS = 'LT.AMT.WORD'
            EB.Foundation.MapLocalFields(APPLICATION.NAMES, LOCAL.FIELDS, FLD.POS)
        
            getLocalFieldData = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)
            getLocalFieldData<1,FLD.POS> = TXTOUT
        
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.LocalRef,getLocalFieldData)
        END
    
        IF AppName EQ 'TELLER' THEN
            APPLICATION.NAMES = 'TELLER'
            LOCAL.FIELDS = 'LT.AMT.WORD'
            EB.Foundation.MapLocalFields(APPLICATION.NAMES, LOCAL.FIELDS, FLD.POS)
            
            getLocalFieldData = EB.SystemTables.getRNew(TT.Contract.Teller.TeLocalRef)
            getLocalFieldData<1,FLD.POS> = TXTOUT
        
            EB.SystemTables.setRNew(TT.Contract.Teller.TeLocalRef,getLocalFieldData)
        END
    
    END
RETURN
END
