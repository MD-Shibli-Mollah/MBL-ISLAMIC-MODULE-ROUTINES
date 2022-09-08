SUBROUTINE CM.MBL.ONLINE.CHRG.CAL(arrId,arrProp,arrCcy,arrRes,balanceAmount,perDat)
*-----------------------------------------------------------------------------
* Subroutine Description:
* THIS ROUTINE FOR ONLINE CHARGE
* Subroutine Type:
* Attached To    : AA.SOURCE.CALC.TYPE(ONLINE.CHRG)
* Attached As    :
*-----------------------------------------------------------------------------
* Modification History :
* 06/04/2020 -                            NEW   - Sarowar Mortoza
*                                                     FDS Pvt Ltd
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_AA.APP.COMMON
    $INSERT I_F.BD.CHG.INFORMATION
    $INSERT I_GTS.COMMON
    $INSERT I_F.MBL.ONLINE.TXN.INFO
    $INSERT I_F.MBL.ONLINE.TXN.CHG.PRM
    
    $USING AA.Framework
    $USING AA.Account
    $USING AC.AccountOpening
    $USING EB.TransactionControl
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING EB.Interface
    $USING EB.Updates
    $USING EB.API
    $USING AA.ActivityRestriction
*-----------------------------------------------------------------------------
    IF EB.SystemTables.getVFunction() EQ 'I' THEN RETURN
    IF EB.SystemTables.getVFunction() EQ 'V' THEN RETURN
    IF EB.SystemTables.getVFunction() EQ 'A' THEN RETURN
    IF (OFS$OPERATION EQ 'VALIDATE' OR OFS$OPERATION EQ 'PROCESS') AND c_aalocCurrActivity EQ 'LENDING-ISSUEBILL-SCHEDULE*DISBURSEMENT.%' THEN RETURN
   
    Y.APP.NAME ="AA.PRD.DES.ACCOUNT"
    LOCAL.FIELDS = ""
    LOCAL.FIELDS = "LT.ONCHG.WAVE"
    FLD.POS = ""
    EB.Updates.MultiGetLocRef(Y.APP.NAME, LOCAL.FIELDS,FLD.POS)
    Y.LT.ONLINE.WAVE.POS=FLD.POS<1,1>

    Y.ARRANGEMENT.ID=c_aalocArrId
    CALL AA.GET.ARRANGEMENT.CONDITIONS(Y.ARRANGEMENT.ID,'ACCOUNT',Y.PROPERTY,'',Y.RET.ID,Y.RET.COND,E.RET.ERR)
    Y.RET.COND = RAISE(Y.RET.COND)
    Y.ONLINE.WAVE = Y.RET.COND<AA.Account.Account.AcLocalRef,Y.LT.ONLINE.WAVE.POS>

    IF Y.ONLINE.WAVE EQ 'YES' THEN
        RETURN
    END

*    IF c_aalocCurrActivity EQ 'ACCOUNTS-CAPITALISE-SCHEDULE' OR c_aalocCurrActivity EQ 'LENDING-MAKEDUE-SCHEDULE' THEN
    IF c_aalocCurrActivity EQ 'ACCOUNTS-CAPITALISE-SCHEDULE' OR c_aalocCurrActivity EQ 'ACCOUNTS-CLOSE-ARRANGEMENT' OR c_aalocCurrActivity EQ 'LENDING-MAKEDUE-SCHEDULE' THEN
        GOSUB INITIALISE ; *
        GOSUB OPENFILE ; *
        GOSUB PROCESS ; *
    END
RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc> </desc>
    FN.BD.CHG = 'F.BD.CHG.INFORMATION'
    F.BD.CHG = ''
    FN.AC = 'F.ACCOUNT'
    F.AC = ''
    FN.MBL.ONTXN.INFO="F.MBL.ONLINE.TXN.INFO"
    F.MBL.ONTXN.INFO=""
    FN.MBL.ONLINE.TXN.CHG.PRM="F.MBL.ONLINE.TXN.CHG.PRM"
    F.MBL.ONLINE.TXN.CHG.PRM=""
    arrangementId = ''
    accountId = ''
    requestDate = ''
    balanceAmount = ''
    retError = ''
    UnAccrued = ''
    Rate = ''
    POS = ''
    BaseBalance = ''
    RequestType = ''
    ReqdDate = ''
    EndDate = ''
    SystemDate = ''
    BalDetails = ''
    ErrorMessage = ''
    CHARGE.AMOUNT = 0
    Y.WORKING.BALANCE = 0
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= OPENFILE>
OPENFILE:
*** <desc> </desc>
    EB.DataAccess.Opf(FN.BD.CHG,F.BD.CHG)
    EB.DataAccess.Opf(FN.AC,F.AC)
    EB.DataAccess.Opf(FN.MBL.ONTXN.INFO, F.MBL.ONTXN.INFO)
    EB.DataAccess.Opf(FN.MBL.ONLINE.TXN.CHG.PRM, F.MBL.ONLINE.TXN.CHG.PRM)
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
    ArrangementId = arrId
    AA.Framework.GetArrangementAccountId(ArrangementId, accountId, Currency, ReturnError)   ;*To get Arrangement Account
    AA.Framework.GetArrangementProduct(ArrangementId, EffDate, ArrRecord, ProductId, PropertyList)  ;*Arrangement record
    Y.PRODUCT.LINE = ArrRecord<AA.Framework.Arrangement.ArrProductLine>
    Y.PRODUCT.GROUP = ArrRecord<AA.Framework.Arrangement.ArrProductGroup>
    Y.PRODUCT.NAME = ArrRecord<AA.Framework.Arrangement.ArrProduct>
    AA.Framework.GetBaseBalanceList(ArrangementId, arrProp, ReqdDate, ProductId, BaseBalance)
    
    RequestType<2> = 'ALL'      ;* Unauthorised Movements required.
    RequestType<3> = 'ALL'      ;* Projected Movements requierd
    RequestType<4> = 'ECB'      ;* Balance file to be used
    RequestType<4,2> = 'END'    ;* Balance required as on TODAY - though Activity date can be less than today
    
    AC.REC = AC.AccountOpening.Account.Read(accountId, Error)
    Y.WORKING.BALANCE =  AC.REC<AC.AccountOpening.Account.WorkingBalance>
    Y.AC.CATG = AC.REC<AC.AccountOpening.Account.Category>
    
    PROP.CLASS.IN = 'ACTIVITY.RESTRICTION'
    AA.Framework.GetArrangementConditions(ArrangementId,PROP.CLASS.IN,PROPERTY,'',RETURN.IDS,RETURN.VALUES.IN,ERR.MSG)
    R.REC.IN = RAISE(RETURN.VALUES.IN)
    Y.PERIODIC.ATTRIBUTE = R.REC.IN<AA.ActivityRestriction.ActivityRestriction.AcrPeriodicAttribute>
    Y.PRIODIC.VALUE = R.REC.IN<AA.ActivityRestriction.ActivityRestriction.AcrPeriodicValue>

    Y.PR.ATTRIBUTE = 'MINIMUM.BAL'
    LOCATE Y.PR.ATTRIBUTE IN Y.PERIODIC.ATTRIBUTE<1,1> SETTING POS THEN
        Y.MIN.BAL=R.REC.IN<AA.ActivityRestriction.ActivityRestriction.AcrPeriodicValue,POS>
    END ELSE
        Y.MIN.BAL=0
    END
                              
    GOSUB GET.ONLINE.TXN.AMT ; *CALCUALTE ONLINE TXN AMOUNT
    
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GET.ONLINE.TXN.AMT>
GET.ONLINE.TXN.AMT:
*** <desc>CALCUALTE ONLINE TXN AMOUNT </desc>
    Y.CUR.MNTH=EB.SystemTables.getToday()[1,6]

    FOR I = 0 TO 5
        Y.TXN.MNTH = Y.CUR.MNTH - I

        Y.ON.TXN.ID=accountId:"-":Y.TXN.MNTH
        
        EB.DataAccess.FRead(FN.MBL.ONTXN.INFO, Y.ON.TXN.ID, R.TXN.REC, F.MBL.ONTXN.INFO, Y.ERR)
           
        Y.CNT=DCOUNT(R.TXN.REC<ONLINE.TXN.REF.NO>,@VM)
        FOR J = 1 TO Y.CNT
            Y.TXN.AMT + = R.TXN.REC<ONLINE.TXN.AMOUNT,J>
        NEXT J

    NEXT I

    IF Y.TXN.AMT GT 0 THEN
        GOSUB GET.ONLINE.CHG.SLAB ; *CALCULATE ONLINE CHAREGE AMOUNT
    END ELSE
        RETURN
    END
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GET.ONLINE.CHG.SLAB>
GET.ONLINE.CHG.SLAB:
*** <desc>CALCULATE ONLINE CHAREGE AMOUNT </desc>
*    EB.DataAccess.FRead(FN.MBL.ONLINE.TXN.CHG.PRM, Y.AC.CATG, R.ONLINE.PRM.REC, F.MBL.ONLINE.TXN.CHG.PRM, Y.ERR)
    
    EB.DataAccess.FRead(FN.MBL.ONLINE.TXN.CHG.PRM, Y.PRODUCT.GROUP, R.ONLINE.PRM.REC, F.MBL.ONLINE.TXN.CHG.PRM, Y.ERR)

    Y.EXCEPTION.PRODUCT=R.ONLINE.PRM.REC<ONLINE.TXNCHG.EXCEPTION.PRODUCT.ID>
    Y.MIN.CHGR.AMT=R.ONLINE.PRM.REC<ONLINE.TXNCHG.MIN.CHARG.AMT>
    Y.EXCLUDE.PRODUCT=R.ONLINE.PRM.REC<ONLINE.TXNCHG.EXCLUDE.PRODUCT.ID>
    
    LOCATE Y.PRODUCT.NAME IN Y.EXCLUDE.PRODUCT<1,1> SETTING POS THEN
        RETURN
    END
            
    IF Y.EXCEPTION.PRODUCT NE '' THEN
        LOCATE Y.PRODUCT.NAME IN Y.EXCEPTION.PRODUCT<1,1> SETTING POS THEN
            Y.CNT.SLAB=DCOUNT(R.ONLINE.PRM.REC<ONLINE.TXNCHG.EXCEPTION.FROM.AMT,POS>,@SM)
            Y.CNT=1
            LOOP
            WHILE Y.CNT LE Y.CNT.SLAB
                Y.FROM.AMT=R.ONLINE.PRM.REC<ONLINE.TXNCHG.EXCEPTION.FROM.AMT,POS,Y.CNT>
                Y.TO.AMT=R.ONLINE.PRM.REC<ONLINE.TXNCHG.EXCEPTION.TO.AMT,POS,Y.CNT>
                Y.CHG.SLAB.AMT=R.ONLINE.PRM.REC<ONLINE.TXNCHG.EXCEPTION.CHG.AMT,POS,Y.CNT>

                IF Y.TXN.AMT GE Y.FROM.AMT AND (Y.TXN.AMT LE Y.TO.AMT OR Y.TO.AMT EQ '') THEN
                    Y.CHRG.AMT= Y.CHG.SLAB.AMT
                    Y.AC.SLAB.AMT=Y.CHG.SLAB.AMT
                    Y.VAT.AMT=Y.CHRG.AMT * 0.15
                END
                Y.CNT++
            REPEAT
        END
    END ELSE
    
        Y.CNT.SLAB=DCOUNT(R.ONLINE.PRM.REC<ONLINE.TXNCHG.FROM.AMT>,@VM)
        Y.CNT=1
        LOOP
        WHILE Y.CNT LE Y.CNT.SLAB
         
            Y.FROM.AMT=R.ONLINE.PRM.REC<ONLINE.TXNCHG.FROM.AMT,Y.CNT>
            Y.TO.AMT=R.ONLINE.PRM.REC<ONLINE.TXNCHG.TO.AMT,Y.CNT>
            Y.CHG.SLAB.AMT=R.ONLINE.PRM.REC<ONLINE.TXNCHG.CHG.AMT,Y.CNT>
        
            IF Y.TXN.AMT GE Y.FROM.AMT AND (Y.TXN.AMT LE Y.TO.AMT OR Y.TO.AMT EQ '') THEN
                Y.CHRG.AMT= Y.CHG.SLAB.AMT
                Y.AC.SLAB.AMT=Y.CHG.SLAB.AMT
                Y.VAT.AMT=Y.CHRG.AMT * 0.15
            END
            Y.CNT++
        REPEAT
    END

    IF c_aalocCurrActivity EQ 'ACCOUNTS-CLOSE-ARRANGEMENT' THEN
        GOSUB CLOSING.CHRG.PROCESS ; *PROCESS ONLINE CHARGE DURING ACCOUNT CLOSING
    END
    
*    IF Y.CHRG.AMT GT 0 THEN
    IF Y.CHRG.AMT GT 0 AND c_aalocCurrActivity NE 'ACCOUNTS-CLOSE-ARRANGEMENT' THEN
        GOSUB CHRG.PROCESS ; *PROCESS ONLINE TXN CHARGE
    END ELSE
        RETURN
    END
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= CHRG.PROCESS>
CHRG.PROCESS:
*** <desc>PROCESS ONLINE TXN CHARGE </desc>
    Y.BD.CHG.ID = accountId:'-':arrProp
    Y.REQIRED.BAL= Y.CHRG.AMT + Y.MIN.BAL + Y.VAT.AMT
       
    EB.DataAccess.FRead(FN.BD.CHG,Y.BD.CHG.ID,R.BD.CHG,F.BD.CHG,BD.ER)
    Y.CNT = DCOUNT(R.BD.CHG<BD.CHG.TXN.DATE>,@VM) + 1
    
    IF Y.CNT > 1 THEN
*        R.BD.CHG<BD.CHG.TXN.DATE,Y.CNT> = EB.SystemTables.getToday()
        R.BD.CHG<BD.CHG.TXN.DATE,Y.CNT> = perDat
        IF Y.WORKING.BALANCE GE Y.REQIRED.BAL THEN
            R.BD.CHG<BD.CHG.BASE.AMT,Y.CNT>=Y.TXN.AMT
            R.BD.CHG<BD.CHG.SLAB.AMT,Y.CNT>=Y.AC.SLAB.AMT
            R.BD.CHG<BD.CHG.TXN.REFNO,Y.CNT>=AA$TXN.REFERENCE
            R.BD.CHG<BD.CHG.TXN.AMT,Y.CNT>=Y.CHRG.AMT
            R.BD.CHG<BD.CHG.TXN.DUE.AMT,Y.CNT>=0
            R.BD.CHG<BD.CHG.TXN.FLAG,Y.CNT>='SCHEDULE'
            R.BD.CHG<BD.TOTAL.CHG.AMT>=R.BD.CHG<BD.TOTAL.CHG.AMT> + Y.CHRG.AMT
            R.BD.CHG<BD.TOTAL.REALIZE.AMT>=R.BD.CHG<BD.TOTAL.REALIZE.AMT> + Y.CHRG.AMT
            R.BD.CHG<BD.OS.DUE.AMT>=R.BD.CHG<BD.OS.DUE.AMT> + 0
        END
    
        IF Y.WORKING.BALANCE LE Y.REQIRED.BAL AND Y.WORKING.BALANCE GT Y.MIN.BAL THEN
            Y.AVAILABLE.WORKING.BAL= Y.WORKING.BALANCE - Y.MIN.BAL
            Y.VAT.AMT= Y.AVAILABLE.WORKING.BAL *.15
            Y.CHRG.TXN.AMT=Y.AVAILABLE.WORKING.BAL - Y.VAT.AMT
              
            R.BD.CHG<BD.CHG.BASE.AMT,Y.CNT>=Y.TXN.AMT
            R.BD.CHG<BD.CHG.SLAB.AMT,Y.CNT>=Y.AC.SLAB.AMT
            R.BD.CHG<BD.CHG.TXN.REFNO,Y.CNT>=AA$TXN.REFERENCE
            R.BD.CHG<BD.CHG.TXN.AMT,Y.CNT>=Y.CHRG.TXN.AMT
            R.BD.CHG<BD.CHG.TXN.DUE.AMT,Y.CNT>=Y.CHRG.AMT - Y.CHRG.TXN.AMT
            R.BD.CHG<BD.CHG.TXN.FLAG,Y.CNT>='SCHEDULE'
            R.BD.CHG<BD.TOTAL.CHG.AMT>=R.BD.CHG<BD.TOTAL.CHG.AMT> + Y.CHRG.AMT
            R.BD.CHG<BD.TOTAL.REALIZE.AMT> = R.BD.CHG<BD.TOTAL.REALIZE.AMT> + Y.CHRG.TXN.AMT
            R.BD.CHG<BD.OS.DUE.AMT> = R.BD.CHG<BD.OS.DUE.AMT> + (Y.CHRG.AMT - Y.CHRG.TXN.AMT)
            Y.CHRG.AMT=Y.CHRG.TXN.AMT
        END
        IF Y.WORKING.BALANCE EQ 0 OR Y.WORKING.BALANCE EQ ''  THEN
            R.BD.CHG<BD.CHG.BASE.AMT,Y.CNT>=Y.TXN.AMT
            R.BD.CHG<BD.CHG.SLAB.AMT,Y.CNT>=Y.AC.SLAB.AMT
            R.BD.CHG<BD.CHG.TXN.REFNO,Y.CNT>=AA$TXN.REFERENCE
            R.BD.CHG<BD.CHG.TXN.AMT,Y.CNT>=0
            R.BD.CHG<BD.CHG.TXN.DUE.AMT,Y.CNT>=Y.CHRG.AMT
            R.BD.CHG<BD.CHG.TXN.FLAG,Y.CNT>='SCHEDULE'
            R.BD.CHG<BD.TOTAL.CHG.AMT>=R.BD.CHG<BD.TOTAL.CHG.AMT> + Y.CHRG.AMT
            R.BD.CHG<BD.TOTAL.REALIZE.AMT>=R.BD.CHG<BD.TOTAL.REALIZE.AMT>
            R.BD.CHG<BD.OS.DUE.AMT>=R.BD.CHG<BD.OS.DUE.AMT> + Y.CHRG.AMT
            Y.CHRG.AMT=0
        END
        IF Y.WORKING.BALANCE LE Y.REQIRED.BAL AND (Y.WORKING.BALANCE GT 0 AND Y.WORKING.BALANCE LE Y.MIN.BAL) THEN
            R.BD.CHG<BD.CHG.BASE.AMT,Y.CNT>=Y.TXN.AMT
            R.BD.CHG<BD.CHG.SLAB.AMT,Y.CNT>=Y.AC.SLAB.AMT
            R.BD.CHG<BD.CHG.TXN.REFNO,Y.CNT>=AA$TXN.REFERENCE
            R.BD.CHG<BD.CHG.TXN.AMT,Y.CNT>=0
            R.BD.CHG<BD.CHG.TXN.DUE.AMT,Y.CNT>=Y.CHRG.AMT
            R.BD.CHG<BD.CHG.TXN.FLAG,Y.CNT>='SCHEDULE'
            R.BD.CHG<BD.TOTAL.CHG.AMT>=R.BD.CHG<BD.TOTAL.CHG.AMT> + Y.CHRG.AMT
            R.BD.CHG<BD.TOTAL.REALIZE.AMT>=R.BD.CHG<BD.TOTAL.REALIZE.AMT>
            R.BD.CHG<BD.OS.DUE.AMT>=R.BD.CHG<BD.OS.DUE.AMT> + Y.CHRG.AMT
            Y.CHRG.AMT=0
        END
    END ELSE
*        R.BD.CHG<BD.CHG.TXN.DATE>=EB.SystemTables.getToday()
        R.BD.CHG<BD.CHG.TXN.DATE>=perDat
        IF Y.WORKING.BALANCE GE Y.REQIRED.BAL THEN
            R.BD.CHG<BD.CHG.BASE.AMT>=Y.TXN.AMT
            R.BD.CHG<BD.CHG.SLAB.AMT>=Y.AC.SLAB.AMT
            R.BD.CHG<BD.CHG.TXN.REFNO>=AA$TXN.REFERENCE
            R.BD.CHG<BD.CHG.TXN.AMT>=Y.CHRG.AMT
            R.BD.CHG<BD.CHG.TXN.DUE.AMT>=0
            R.BD.CHG<BD.CHG.TXN.FLAG>='SCHEDULE'
            R.BD.CHG<BD.TOTAL.CHG.AMT>=Y.CHRG.AMT
            R.BD.CHG<BD.TOTAL.REALIZE.AMT>=Y.CHRG.AMT
            R.BD.CHG<BD.OS.DUE.AMT>=0
        END
        IF Y.WORKING.BALANCE LE Y.REQIRED.BAL AND Y.WORKING.BALANCE GT Y.MIN.BAL THEN
            Y.AVAILABLE.WORKING.BAL= Y.WORKING.BALANCE - Y.MIN.BAL
            Y.VAT.AMT= Y.AVAILABLE.WORKING.BAL *.15
            Y.CHRG.TXN.AMT=Y.AVAILABLE.WORKING.BAL - Y.VAT.AMT
              
            R.BD.CHG<BD.CHG.BASE.AMT>=Y.TXN.AMT
            R.BD.CHG<BD.CHG.SLAB.AMT>=Y.AC.SLAB.AMT
            R.BD.CHG<BD.CHG.TXN.REFNO>=AA$TXN.REFERENCE
            R.BD.CHG<BD.CHG.TXN.AMT>=Y.CHRG.TXN.AMT
            R.BD.CHG<BD.CHG.TXN.DUE.AMT>=Y.CHRG.AMT - Y.CHRG.TXN.AMT
            R.BD.CHG<BD.CHG.TXN.FLAG>='SCHEDULE'
            R.BD.CHG<BD.TOTAL.CHG.AMT>=Y.CHRG.AMT
            R.BD.CHG<BD.TOTAL.REALIZE.AMT> = Y.CHRG.TXN.AMT
            R.BD.CHG<BD.OS.DUE.AMT> = Y.CHRG.AMT - Y.CHRG.TXN.AMT
            Y.CHRG.AMT=Y.CHRG.TXN.AMT
        END
        IF Y.WORKING.BALANCE EQ 0 OR Y.WORKING.BALANCE EQ ''  THEN
            R.BD.CHG<BD.CHG.BASE.AMT>=Y.TXN.AMT
            R.BD.CHG<BD.CHG.SLAB.AMT>=Y.AC.SLAB.AMT
            R.BD.CHG<BD.CHG.TXN.REFNO>=AA$TXN.REFERENCE
            R.BD.CHG<BD.CHG.TXN.AMT>=0
            R.BD.CHG<BD.CHG.TXN.DUE.AMT>=Y.CHRG.AMT
            R.BD.CHG<BD.CHG.TXN.FLAG>='SCHEDULE'
            R.BD.CHG<BD.TOTAL.CHG.AMT>=Y.CHRG.AMT
            R.BD.CHG<BD.TOTAL.REALIZE.AMT>=0
            R.BD.CHG<BD.OS.DUE.AMT>=Y.CHRG.AMT
            Y.CHRG.AMT=0
        END
        IF Y.WORKING.BALANCE LE Y.REQIRED.BAL AND (Y.WORKING.BALANCE GT 0 AND Y.WORKING.BALANCE LE Y.MIN.BAL) THEN
            R.BD.CHG<BD.CHG.BASE.AMT>=Y.TXN.AMT
            R.BD.CHG<BD.CHG.SLAB.AMT>=Y.AC.SLAB.AMT
            R.BD.CHG<BD.CHG.TXN.REFNO>=AA$TXN.REFERENCE
            R.BD.CHG<BD.CHG.TXN.AMT>=0
            R.BD.CHG<BD.CHG.TXN.DUE.AMT>=Y.CHRG.AMT
            R.BD.CHG<BD.CHG.TXN.FLAG>='SCHEDULE'
            R.BD.CHG<BD.TOTAL.CHG.AMT>=Y.CHRG.AMT
            R.BD.CHG<BD.TOTAL.REALIZE.AMT>=0
            R.BD.CHG<BD.OS.DUE.AMT>=Y.CHRG.AMT
            Y.CHRG.AMT=0
        END
    END
    
    R.BD.CHG<BD.CO.CODE> = EB.SystemTables.getIdCompany()
    EB.DataAccess.FWrite(FN.BD.CHG,Y.BD.CHG.ID,R.BD.CHG)
    EB.TransactionControl.JournalUpdate(Y.BD.CHG.ID)
    balanceAmount = Y.CHRG.AMT
         
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= CLOSING.CHRG.PROCESS>
CLOSING.CHRG.PROCESS:
*** <desc>PROCESS ONLINE CHARGE DURING ACCOUNT CLOSING </desc>
    Y.BD.CHG.ID = accountId:'-':arrProp
    EB.DataAccess.FRead(FN.BD.CHG,Y.BD.CHG.ID,R.BD.CHG,F.BD.CHG,BD.CHG.ER)
    balanceAmount = R.BD.CHG<BD.OS.DUE.AMT> + Y.AC.SLAB.AMT
RETURN
*** </region>

END








