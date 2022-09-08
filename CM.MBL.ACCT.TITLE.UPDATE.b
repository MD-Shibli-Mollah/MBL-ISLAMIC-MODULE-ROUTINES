* @ValidationCode : MjoxMTkwMjI3NjkzOkNwMTI1MjoxNTkxMTE4MzgwMjY5OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 02 Jun 2020 23:19:40
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE CM.MBL.ACCT.TITLE.UPDATE
*-----------------------------------------------------------------------------
** Subroutine Description:

* THIS ROUTINE USE FOR RETRIVE CUSTOMER TITLE , CUSTOMER SHORT NAME AND VALIDATE NOMINEE SHARE
* Subroutine Type:
* Attached To    : ACTIVITY.API
* Attached As    : PREE.ROUTINE ACTIVITY.API, ACTIVITY.ID -ACCOUNTS-NEW-ARRANGEMENT, PROPERTY.CLASS - ACCOUNT, PC.ACTION - MAINTAIN


*-----------------------------------------------------------------------------
* Modification History :
* 10/06/2020                             NEW - MEHEDI
* 18/06/2020                            Add New Code  - Sarowar Mortoza
* Modification Description  Add new validation for Nominee Share
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.APP.COMMON
    $INSERT I_AA.LOCAL.COMMON
*
    $USING EB.SystemTables
    $USING AA.Framework
    $USING EB.DataAccess
    $USING ST.Customer
    $USING EB.Updates
    $USING AA.Account
    $USING EB.ErrorProcessing
*-----------------------------------------------------------------------------
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
    
    Y.APP.NAME ="AA.PRD.DES.ACCOUNT"
    LOCAL.FIELDS = ""
    LOCAL.FIELDS = "LT.AC.NM.SHARE"
    FLD.POS = ""
    EB.Updates.MultiGetLocRef(Y.APP.NAME, LOCAL.FIELDS,FLD.POS)
    Y.LT.SHARE.POS=FLD.POS<1,1>
    Y.NOM.SHARE = EB.SystemTables.getRNew(AA.Account.Account.AcLocalRef)<1,Y.LT.SHARE.POS>
    IF Y.NOM.SHARE NE '' THEN
        GOSUB NOMINEE.VAL
    END

RETURN
*----
INIT:
*----
    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER = ''
RETURN
*---------
OPENFILES:
*---------
    EB.DataAccess.Opf(FN.CUSTOMER,F.CUSTOMER)
RETURN
*-------
PROCESS:
*-------
    Y.CUS.ID = c_aalocArrActivityRec<AA.Framework.ArrangementActivity.ArrActCustomer>
    EB.DataAccess.FRead(FN.CUSTOMER, Y.CUS.ID, R.CUS, F.CUSTOMER, ERR.CUS)
    Y.CUS.NM.1=R.CUS<ST.Customer.Customer.EbCusNameOne>
    Y.CUS.NM.2=R.CUS<ST.Customer.Customer.EbCusNameTwo>
    Y.CUS.SHT.NM=R.CUS<ST.Customer.Customer.EbCusShortName>
    
    IF EB.SystemTables.getRNew(AA.Account.Account.AcAccountTitleOne) EQ '' THEN
        EB.SystemTables.setRNew(AA.Account.Account.AcAccountTitleOne,Y.CUS.NM.1)
    END

    IF EB.SystemTables.getRNew(AA.Account.Account.AcAccountTitleTwo) EQ '' THEN
        EB.SystemTables.setRNew(AA.Account.Account.AcAccountTitleTwo,Y.CUS.NM.2)
    END
    
    IF EB.SystemTables.getRNew(AA.Account.Account.AcShortTitle) EQ '' THEN
        EB.SystemTables.setRNew(AA.Account.Account.AcShortTitle,Y.CUS.SHT.NM)
    END
    
RETURN
*------------
NOMINEE.VAL:
*---------
** NOMINEE SHARE CALCULATION VALIDATION, TOTAL NOMINEE SHARE
** CAN NOT BE GETTER THAN 100 AND LESS THAN 100

    Y.CNT = DCOUNT(Y.NOM.SHARE,@SM)
    Y.TOT = 0

    FOR I = 1 TO Y.CNT
        Y.VAL = Y.NOM.SHARE<1,1,I>
        Y.TOT += Y.VAL
    NEXT I

    IF (Y.TOT LT '100') OR (Y.TOT GT '100') THEN
        EB.SystemTables.setAf(AA.Account.Account.AcLocalRef)
        EB.SystemTables.setAv(Y.LT.SHARE.POS)
        EB.SystemTables.setEtext("Total Nominee Share should not be LT 100 or GT 100")
        EB.ErrorProcessing.StoreEndError()
    END
RETURN
END
