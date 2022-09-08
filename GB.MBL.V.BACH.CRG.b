SUBROUTINE GB.MBL.V.BACH.CRG
*-----------------------------------------------------------------------------
* Subroutine Description:
* Routine Attach To: Validation rtn on validation field COMMISSION.CODE
* Routine Attach Version: FUNDS.TRANSFER,MBL.OW.CLG
*-----------------------------------------------------------------------------
* Modification History :
* 20/03/2020 -                             Retrofit   -MD. SAROWAR MORTOZA
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
    FN.FT = 'F.FUNDS.TRANSFER'
    F.FT = ''
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= OPENFILE>
OPENFILE:
*** <desc> </desc>
    EB.DataAccess.Opf(FN.FT, F.FT)
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
    
    Y.COMM.CODE=EB.SystemTables.getComi()
    Y.CATEG.AC=""
    Y.CATEG.AC = 'BDT140250001'
    Y.COMPANY=EB.SystemTables.getIdCompany()[6,4]
    EB.SystemTables.setRNew(FT.Contract.FundsTransfer.DebitAcctNo, Y.CATEG.AC:Y.COMPANY)
    
    
    IF Y.COMM.CODE = 'DEBIT PLUS CHARGES' THEN
        Y.CR.AC.NO = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditAcctNo)
        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.ChargesAcctNo, Y.CR.AC.NO)
        
        IF Y.CLG.TYPE = 'RV' THEN
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CommissionType, 'BACHCHGRV')
        END

        IF Y.CLG.TYPE = 'HV' THEN
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CommissionType, 'BACHCHGHV')
        END
    END
    
    IF Y.COMM.CODE = 'CREDIT LESS CHARGES' THEN
        EB.SystemTables.setEtext('Credit Less Charges not Allowed')
        EB.ErrorProcessing.StoreEndError()
    END
        
RETURN
*** </region>

END



