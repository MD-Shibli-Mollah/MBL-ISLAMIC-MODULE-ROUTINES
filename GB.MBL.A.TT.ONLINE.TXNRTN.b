SUBROUTINE GB.MBL.A.TT.ONLINE.TXNRTN
*-----------------------------------------------------------------------------
* Subroutine Description:
* THIS ROUTINE IS USE AFTER ONLINE TT TRANSACTION IS AUTHORIZE THEN IT WRITE INTO
* LOCAL TABLE MBL.ONLINE.TXN.INFO
* ATTACH TO : TELLER VERSION.CONTROL
* ATTACH AS : AUTH ROUTINE
*-----------------------------------------------------------------------------
* Modification History :
* 07/04/2020 -                            NEW   - Sarowar Mortoza
*                                                     FDS Pvt Ltd
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING AC.AccountOpening
    $USING TT.Contract
    $USING AA.Framework
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.ErrorProcessing
    $INSERT I_F.MBL.ONLINE.TXN.INFO
*-----------------------------------------------------------------------------
    GOSUB INITIALISE ; *
    GOSUB OPENFILE ; *
    GOSUB PROCESS ; *
RETURN
*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc> </desc>
    FN.TT = "F.TELLER"
    F.TT = ""
    FN.AC="F.ACCOUNT"
    F.AC=""
    FN.MBL.ONTXN.INFO="F.MBL.ONLINE.TXN.INFO"
    F.MBL.ONTXN.INFO=""
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= OPENFILE>
OPENFILE:
*** <desc> </desc>
    EB.DataAccess.Opf(FN.TT,F.TT)
    EB.DataAccess.Opf(FN.AC, F.AC)
    EB.DataAccess.Opf(FN.MBL.ONTXN.INFO, F.MBL.ONTXN.INFO)
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
    Y.TXN.ID = EB.SystemTables.getIdNew()
    Y.OP.CO.CODE=EB.SystemTables.getRNew(TT.Contract.Teller.TeCoCode)
    Y.TT.AMT=EB.SystemTables.getRNew(TT.Contract.Teller.TeAmountLocalOne)
    Y.DR.CR.MARKER= EB.SystemTables.getRNew(TT.Contract.Teller.TeDrCrMarker)
    Y.TXN.DATE= EB.SystemTables.getRNew(TT.Contract.Teller.TeValueDateTwo)
    Y.TT.AC= EB.SystemTables.getRNew(TT.Contract.Teller.TeAccountOne)
    Y.CHK.INT.ACT = Y.TT.AC[1,3]

    IF NOT(ALPHA(Y.CHK.INT.ACT)) THEN
        Y.DR.AC= EB.SystemTables.getRNew(TT.Contract.Teller.TeAccountOne)
    END
    
    EB.DataAccess.FRead(FN.AC, Y.DR.AC, R.DR.AC.REC, F.AC, Y.ERR)
    Y.DR.AC.CO.CODE=R.DR.AC.REC<AC.AccountOpening.Account.CoCode>
    Y.DR.AC.CATAG=R.DR.AC.REC<AC.AccountOpening.Account.Category>
   
    Y.TT.DR.AC= EB.SystemTables.getRNew(TT.Contract.Teller.TeAccountTwo)
    Y.CHK.INT.ACT2 = Y.TT.DR.AC[1,3]
    IF NOT(ALPHA(Y.CHK.INT.ACT2)) THEN
        Y.CR.AC=EB.SystemTables.getRNew(TT.Contract.Teller.TeAccountTwo)
    END
        
    EB.DataAccess.FRead(FN.AC, Y.CR.AC, R.CR.AC.REC, F.AC, Y.ERR)
    Y.CR.AC.CO.CODE=R.CR.AC.REC<AC.AccountOpening.Account.CoCode>
    Y.CR.AC.CATAG=R.CR.AC.REC<AC.AccountOpening.Account.Category>
   
    IF (Y.DR.AC.CO.CODE NE Y.OP.CO.CODE AND Y.DR.AC.CO.CODE NE '') OR (Y.CR.AC.CO.CODE NE Y.OP.CO.CODE AND Y.CR.AC.CO.CODE NE '') THEN
        ONLINE.FLAG = 1
    END ELSE
        ONLINE.FLAG = 0
    END

    IF  ONLINE.FLAG EQ '1' THEN
        GOSUB WRITE.ONLINE.TXN.INFO ; *ONLINE TXN WRITE TO MBL.ONLINE.TXN.INFO TBALE
    END
    
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= WRITE.ONLINE.TXN.INFO>
WRITE.ONLINE.TXN.INFO:
*** <desc>ONLINE TXN WRITE TO MBL.ONLINE.TXN.INFO TBALE </desc>
    Y.CUR.MNTH=EB.SystemTables.getToday()[1,6]
    IF Y.DR.AC NE '' THEN
        Y.DR.ID=Y.DR.AC:"-":Y.CUR.MNTH
        Y.CTG=Y.DR.AC.CATAG
        Y.AC.CO.CODE=Y.DR.AC.CO.CODE
    END
    IF Y.CR.AC NE '' THEN
        Y.CR.ID=Y.CR.AC:"-":Y.CUR.MNTH
        Y.CTG=Y.CR.AC.CATAG
        Y.AC.CO.CODE=Y.CR.AC.CO.CODE
    END
  
    IF Y.DR.AC NE '' THEN
        EB.DataAccess.FRead(FN.MBL.ONTXN.INFO, Y.DR.ID, R.TXN.REC, F.MBL.ONTXN.INFO, Y.ERR)
        Y.ONLINE.TXN.CNT=DCOUNT(R.TXN.REC<ONLINE.TXN.REF.NO>,@VM)+1
        IF Y.ONLINE.TXN.CNT > 1 THEN
            R.TXN.REC<ONLINE.TXN.AC.CATEGORY>=Y.CTG
            R.TXN.REC<ONLINE.TXN.REF.NO,Y.ONLINE.TXN.CNT>=Y.TXN.ID
            R.TXN.REC<ONLINE.TXN.DATE,Y.ONLINE.TXN.CNT>=Y.TXN.DATE
            R.TXN.REC<ONLINE.TXN.DR.OR.CR,Y.ONLINE.TXN.CNT>=Y.DR.CR.MARKER
            R.TXN.REC<ONLINE.TXN.AMOUNT,Y.ONLINE.TXN.CNT>=Y.TT.AMT
            R.TXN.REC<ONLINE.TXN.OP.CO.CODE,Y.ONLINE.TXN.CNT>=Y.OP.CO.CODE
            R.TXN.REC<ONLINE.TXN.AC.CO.CODE>=Y.AC.CO.CODE
            WRITE R.TXN.REC TO F.MBL.ONTXN.INFO,Y.DR.ID
        END ELSE
            R.TXN.REC<ONLINE.TXN.AC.CATEGORY>=Y.CTG
            R.TXN.REC<ONLINE.TXN.REF.NO>=Y.TXN.ID
            R.TXN.REC<ONLINE.TXN.DATE>=Y.TXN.DATE
            R.TXN.REC<ONLINE.TXN.DR.OR.CR>=Y.DR.CR.MARKER
            R.TXN.REC<ONLINE.TXN.AMOUNT>=Y.TT.AMT
            R.TXN.REC<ONLINE.TXN.OP.CO.CODE>=Y.OP.CO.CODE
            R.TXN.REC<ONLINE.TXN.AC.CO.CODE>=Y.AC.CO.CODE
            WRITE R.TXN.REC TO F.MBL.ONTXN.INFO,Y.DR.ID
        END
    END

    IF Y.CR.AC NE '' THEN
        EB.DataAccess.FRead(FN.MBL.ONTXN.INFO, Y.CR.ID, R.TXN.REC, F.MBL.ONTXN.INFO, Y.ERR)
        Y.ONLINE.TXN.CNT=DCOUNT(R.TXN.REC<ONLINE.TXN.REF.NO>,@VM)+1
        IF Y.ONLINE.TXN.CNT > 1 THEN
            R.TXN.REC<ONLINE.TXN.AC.CATEGORY>=Y.CTG
            R.TXN.REC<ONLINE.TXN.REF.NO,Y.ONLINE.TXN.CNT>=Y.TXN.ID
            R.TXN.REC<ONLINE.TXN.DATE,Y.ONLINE.TXN.CNT>=Y.TXN.DATE
            R.TXN.REC<ONLINE.TXN.DR.OR.CR,Y.ONLINE.TXN.CNT>=Y.DR.CR.MARKER
            R.TXN.REC<ONLINE.TXN.AMOUNT,Y.ONLINE.TXN.CNT>=Y.TT.AMT
            R.TXN.REC<ONLINE.TXN.OP.CO.CODE,Y.ONLINE.TXN.CNT>=Y.OP.CO.CODE
            R.TXN.REC<ONLINE.TXN.AC.CO.CODE>=Y.AC.CO.CODE
            WRITE R.TXN.REC TO F.MBL.ONTXN.INFO,Y.CR.ID
        END ELSE
            R.TXN.REC<ONLINE.TXN.AC.CATEGORY>=Y.CTG
            R.TXN.REC<ONLINE.TXN.REF.NO>=Y.TXN.ID
            R.TXN.REC<ONLINE.TXN.DATE>=Y.TXN.DATE
            R.TXN.REC<ONLINE.TXN.DR.OR.CR>=Y.DR.CR.MARKER
            R.TXN.REC<ONLINE.TXN.AMOUNT>=Y.TT.AMT
            R.TXN.REC<ONLINE.TXN.OP.CO.CODE>=Y.OP.CO.CODE
            R.TXN.REC<ONLINE.TXN.AC.CO.CODE>=Y.AC.CO.CODE
            WRITE R.TXN.REC TO F.MBL.ONTXN.INFO,Y.CR.ID
        END
    END
   
RETURN
*** </region>

END




