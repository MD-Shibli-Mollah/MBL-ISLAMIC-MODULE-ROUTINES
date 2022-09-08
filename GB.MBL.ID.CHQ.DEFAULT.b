SUBROUTINE GB.MBL.ID.CHQ.DEFAULT
*-----------------------------------------------------------------------------
*Subroutine Description:This routine is used to form a new ID ( CDA,CDB,SBA,PO,PS,SDR)
*                       based on the type of Cheque Issued.
*                       This Routine differentiates between SB,CD,PO,PS,SDR Cheques based on Category.
*Subroutine Type:
*Attached To    : version(CHEQUE.ISSUE,MBL.CDA.PRINT,CHEQUE.ISSUE,MBL.CA.PRINT,CHEQUE.ISSUE,MBL.CDB.PRINT,CHEQUE.ISSUE,MBL.SBA.PRINT,CHEQUE.ISSUE,MBL.SA.PRINT)
*Attached As    : ID ROUTINE
*-----------------------------------------------------------------------------
* Modification History :
* 17/02/2020 -                            Retrofit   - MD. EBRAHIM KHALIL RIAN,
*                                                 FDS Bangladesh Limited
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    
    $USING ST.Customer
    $USING ST.ChqIssue
    $USING ST.ChqConfig
    $USING AC.AccountOpening

    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.ErrorProcessing
*-----------------------------------------------------------------------------
    GOSUB INITIALISE ; *INITIALISATION
    GOSUB OPENFILE ; *FILE OPEN
    GOSUB PROCESS ; *PROCESS BUSINESS LOGIC
RETURN
*-----------------------------------------------------------------------------

*** <region namEB.SystemTables.setE(INITIALISE>
INITIALISE:
*** <desc>INITIALISATION </desc>
    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER = ''
   
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    
    FN.CHEQUE.TYPE = 'F.CHEQUE.TYPE'
    F.CHEQUE.TYPE = ''
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= OPENFILE>
OPENFILE:
*** <desc>FILE OPEN </desc>
    EB.DataAccess.Opf(FN.CUSTOMER,F.CUSTOMER)
    EB.DataAccess.Opf(FN.ACCOUNT,F.ACCOUNT)
    EB.DataAccess.Opf(FN.CHEQUE.TYPE,F.CHEQUE.TYPE)
RETURN
*** </region>

*** <region name= PROCESS>
PROCESS:
*** <desc>PROCESS BUSINESS LOGIC </desc>
    Y.ID = EB.SystemTables.getComi()

    Y.VER.NAME = EB.SystemTables.getPgmVersion()
    Y.ACC.NO = FIELD(Y.ID,".",2)
    Y.CHQ.TYPE = FIELD(Y.ID,".",1)

    Y.CHQ.CODE = Y.CHQ.TYPE[1,2]

    R.ACCOUNT = ''
    Y.ACCOUNT.ERR = ''
    EB.DataAccess.FRead(FN.ACCOUNT,Y.ACC.NO,R.ACCOUNT,F.ACCOUNT,Y.ACCOUNT.ERR)
    Y.CATEGORY = R.ACCOUNT<AC.AccountOpening.Account.Category>


****START********
    !Allow other branch's staff account cheque issue
    !Modified on date 16072016 by Amirul Islam


    Y.AC.CO.CODE= R.ACCOUNT<AC.AccountOpening.Account.CoCode>
    Y.USER.CO.CODE= EB.SystemTables.getIdCompany()

    IF Y.USER.CO.CODE NE Y.AC.CO.CODE THEN
        IF Y.CATEGORY NE 6003 THEN
            EB.SystemTables.setEtext("For other branch's account, only staff account is allowed")
            EB.ErrorProcessing.StoreEndError()
        END
    END


******END******


    BEGIN CASE
        CASE EB.SystemTables.getPgmVersion() EQ ',MBL.CDA.PRINT'

            Y.CHQ.TYPE = 'CDA'
            GOSUB READ.CHEQUE.TYPE
            IF Y.FLAG THEN
                EB.SystemTables.setComi("CDA.":Y.ACC.NO)
            END ELSE
                EB.SystemTables.setEtext("Error!! Not a CD Account.")
                EB.ErrorProcessing.StoreEndError()
            END


        CASE EB.SystemTables.getPgmVersion() EQ ',MBL.CDB.PRINT'

            Y.CHQ.TYPE = 'CDB'
            GOSUB READ.CHEQUE.TYPE
            IF Y.FLAG THEN
                EB.SystemTables.setComi("CDB.":Y.ACC.NO)
            END ELSE
                EB.SystemTables.setEtext("Error!! Not a CD Account.")
                EB.ErrorProcessing.StoreEndError()
            END
************
            !Modified on date 16072016 by Amirul Islam

        CASE EB.SystemTables.getPgmVersion() EQ ',MBL.CA.PRINT'

            Y.CHQ.TYPE = 'CA'
            GOSUB READ.CHEQUE.TYPE
            IF Y.FLAG THEN
                EB.SystemTables.setComi("CA.":Y.ACC.NO)
            END ELSE
                EB.SystemTables.setEtext("Error!! Not a CD Account.")
                EB.ErrorProcessing.StoreEndError()
            END


*************

        CASE EB.SystemTables.getPgmVersion() EQ ',MBL.SBA.PRINT'

            Y.CHQ.TYPE = 'SBA'
            GOSUB READ.CHEQUE.TYPE
            IF Y.FLAG THEN
                EB.SystemTables.setComi("SBA.":Y.ACC.NO)
            END ELSE
                EB.SystemTables.setEtext("Error!! Not a SB Account.")
                EB.ErrorProcessing.StoreEndError()
            END

        CASE EB.SystemTables.getPgmVersion() EQ ',MBL.SA.PRINT'

            Y.CHQ.TYPE = 'SA'
            GOSUB READ.CHEQUE.TYPE
            IF Y.FLAG THEN
                EB.SystemTables.setComi("SA.":Y.ACC.NO)
            END ELSE
                EB.SystemTables.setEtext("Error!! Not a SB Account.")
                EB.ErrorProcessing.StoreEndError()
            END

*        CASE EB.SystemTables.getPgmVersion() EQ ',BD.PO.CHQ.ISS'
*
*            Y.CHQ.TYPE = 'PO'
*            GOSUB READ.CHEQUE.TYPE
*            IF Y.FLAG THEN
*                EB.SystemTables.setComi("PO.":Y.ACC.NO)
*            END ELSE
*                EB.SystemTables.setE("Error!! Not a PO Account.")
*                EB.ErrorProcessing.Err()
*            END
*
*        CASE EB.SystemTables.getPgmVersion() EQ ',BD.PS.CHQ.ISS'
*
*            Y.CHQ.TYPE = 'PS'
*            GOSUB READ.CHEQUE.TYPE
*            IF Y.FLAG THEN
*                EB.SystemTables.setComi("PS.":Y.ACC.NO)
*            END ELSE
*                EB.SystemTables.setE("Error!! Not a PS Account.")
*                EB.ErrorProcessing.Err()
*            END
*
*        CASE EB.SystemTables.getPgmVersion() EQ ',BD.SDR.CHQ.ISS'
*
*            Y.CHQ.TYPE = 'SDR'
*            GOSUB READ.CHEQUE.TYPE
*            IF Y.FLAG THEN
*                EB.SystemTables.setComi("SDR.":Y.ACC.NO)
*            END ELSE
*                EB.SystemTables.setE("Error!! Not a SDR Account.")
*                EB.ErrorProcessing.Err()
*            END

    END CASE
RETURN
*** </region>

*** <region name= READ.CHEQUE.TYPE>
READ.CHEQUE.TYPE:
*** <desc>READ.CHEQUE.TYPE</desc>
    R.CHEQUE.TYPE = ''
    Y.CHEQUE.TYPE = ''
    EB.DataAccess.FRead(FN.CHEQUE.TYPE,Y.CHQ.TYPE,R.CHEQUE.TYPE,F.CHEQUE.TYPE,Y.CHEQUE.TYPE.ERR)
    Y.CHQ.CAT = R.CHEQUE.TYPE<ST.ChqConfig.ChequeType.ChequeTypeCategory>

    Y.FLAG = INDEX(Y.CHQ.CAT,Y.CATEGORY,1)
RETURN
*** </region>
END
