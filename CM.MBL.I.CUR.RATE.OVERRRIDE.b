SUBROUTINE CM.MBL.I.CUR.RATE.OVERRRIDE
*-----------------------------------------------------------------------------
* Subroutine Description:
* THIS ROUTINE FOR CREATE DISPO OVERIRDE WHEN FOREIGN CURRENCY  SPREAD RATE IS GT 0.10
* DURING FT AND TF SETTLEMENT
* Subroutine Type:
* Attached To    : EB.GC.CONSTRAINTS
* Attached As    :
*-----------------------------------------------------------------------------
* Modification History :
* 22/04/2020 -                            NEW   - Sarowar Mortoza
*                                                     FDS Pvt Ltd
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_AA.APP.COMMON
    $USING FT.Contract
    $USING LC.Contract
    $USING ST.CurrencyConfig
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING EB.OverrideProcessing
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
    F.FT = ""
    FN.FT.NAU = "F.FUNDS.TRANSFER$NAU"
    F.FT.NAU = ""
    
    FN.DRAW="F.DRAWINGS"
    F.DRAW=""
    
    FN.CUR="F.CURRENCY"
    F.CUR=""
        
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= OPENFILE>
OPENFILE:
*** <desc> </desc>
    EB.DataAccess.Opf(FN.FT, F.FT)
    EB.DataAccess.Opf(FN.DRAW, F.DRAW)
    EB.DataAccess.Opf(FN.CUR,F.CUR)

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
    Y.TXN.ID = EB.SystemTables.getIdNew()
    IF EB.SystemTables.getApplication() EQ 'FUNDS.TRANSFER' THEN
        GOSUB GET.FT.INFO ; *
    END
    IF EB.SystemTables.getApplication() EQ 'DRAWINGS' THEN
        GOSUB GET.DRAWINGS.INFO ; *
    END
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GET.FT.INFO>
GET.FT.INFO:
*** <desc> </desc>
    Y.TREASURY.RATE=EB.SystemTables.getRNew(FT.Contract.FundsTransfer.TreasuryRate)
    Y.CUS.SPREAD=EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CustomerSpread)
    Y.CUS.RATE=EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CustomerRate)
    Y.CUS.SPREAD=ABS(Y.CUS.SPREAD)
    
    IF Y.TREASURY.RATE NE Y.CUS.RATE AND Y.CUS.SPREAD GT 0.10 THEN
        Y.OVERR.ID = 'EB-MBL.TREASURY.RATE'
        EB.SystemTables.setText(Y.OVERR.ID)
        Y.OVERRIDE.VAL = EB.SystemTables.getRNew(V-9)
        Y.OVRRD.NO = DCOUNT(Y.OVERRIDE.VAL,VM) + 1
        EB.OverrideProcessing.StoreOverride(Y.OVRRD.NO)
        RETURN
    END

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GET.DRAWINGS.INFO>
GET.DRAWINGS.INFO:
*** <desc> </desc>
    Y.RATE.BOOKED=EB.SystemTables.getRNew(LC.Contract.Drawings.TfDrRateBooked)
    Y.RATE.SPREAD=EB.SystemTables.getRNew(LC.Contract.Drawings.TfDrRateSpread)
    Y.RATE.SPREAD=ABS(Y.RATE.SPREAD)
    
    Y.TREASURY.RATE=EB.SystemTables.getRNew(LC.Contract.Drawings.TfDrTreasuryRate)
    Y.CUS.SPREAD=EB.SystemTables.getRNew(LC.Contract.Drawings.TfDrCustomerSpread)
    Y.CUS.SPREAD=ABS(Y.CUS.SPREAD)
    
    IF Y.RATE.SPREAD GT 0.10 OR Y.CUS.SPREAD GT 0.10 THEN
        Y.OVERR.ID = 'EB-MBL.TREASURY.RATE  '
        EB.SystemTables.setText(Y.OVERR.ID)
        Y.OVERRIDE.VAL = EB.SystemTables.getRNew(V-9)
        Y.OVRRD.NO = DCOUNT(Y.OVERRIDE.VAL,VM) + 1
        EB.OverrideProcessing.StoreOverride(Y.OVRRD.NO)
        RETURN
    END

RETURN
*** </region>

END






