SUBROUTINE GB.MBL.CLG.VALIDATION
*-----------------------------------------------------------------------------
* Subroutine Description:
*This rtn use for check high value validation
*Routine Attach To: Input routine
*Routine Attach Version: FUNDS.TRANSFER,MBL.OW.CLG
*-----------------------------------------------------------------------------
* Modification History :
* 20/03/2020 -                             Retrofit   -MD.SAROWAR MORTOZA
*                                                 FDS Bangladesh Limited
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING FT.Contract
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.Foundation
    $USING EB.ErrorProcessing
*-----------------------------------------------------------------------------
    GOSUB INITIALISE ; *
    GOSUB OPENFILE ; *
    GOSUB PROCESS ; *
RETURN
*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc> </desc>
    FN.FT = "F.FUNDS.TRANSFER"
    F.FT = ''
  
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= OPENFILE>
OPENFILE:
*** <desc> </desc>
    EB.DataAccess.Opf(FN.FT, F.FT)

    Y.CLG.TYPE = ''
    Y.CATEG.AC = ''
    Y.CR.AMT = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditAmount)
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
    Y.CLG.TYPE.POS=""
    Y.APP.NAME ="FUNDS.TRANSFER"
    LOCAL.FIELDS = ""
    LOCAL.FIELDS = "LT.CLG.TYPE"
    FLD.POS = ""
    EB.Foundation.MapLocalFields(Y.APP.NAME, LOCAL.FIELDS,FLD.POS)
    Y.CLG.TYPE.POS=FLD.POS<1,1>
    Y.CLG.TYPE=EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)<1,Y.CLG.TYPE.POS>

    IF Y.CR.AMT LT '500000' AND Y.CLG.TYPE EQ 'HV' THEN
        EB.SystemTables.setEtext('High Value Cheque Can Not Be Below 500000')
        EB.ErrorProcessing.StoreEndError()
    END

    IF EB.SystemTables.getPgmVersion() EQ ',MBL.IW.CLG' THEN
        Y.CATEG.AC = 'BDT140310001'
        Y.COMPANY=EB.SystemTables.getIdCompany()[6,4]
        Y.CR.ACCT= Y.CATEG.AC:Y.COMPANY
        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CreditAcctNo, Y.CR.ACCT)
    END
RETURN
*** </region>

END



