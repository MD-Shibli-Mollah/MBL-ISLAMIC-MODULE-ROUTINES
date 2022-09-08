* @ValidationCode : MjotNjIxNDEyMTkwOkNwMTI1MjoxNTkzOTczMjkyNDkzOkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 06 Jul 2020 00:21:32
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0

SUBROUTINE GB.MBL.ACCOUNT.STATEMENT
*-------------------------------------------------------------------------
    $USING AC.AccountOpening
    $USING ST.AccountStatement
    $USING AC.Config
    $USING AC.HighVolume
    $USING EB.Utility
    $USING EB.SystemTables
    $USING EB.Reports
    $USING EB.API
    $USING DE.Config
    $USING ST.CompanyCreation
    $USING AC.API
    $USING ST.Customer

*------------------------------------------------------------------------
*
    GOSUB INITIALISATION
    GOSUB GET.HANDOFF.RECORD
    GOSUB GET.ADDRESS         ;* Need handoff to determine address
*
    CONVERT @FM TO "~" IN R.DE.ADDRESS  ;* Separate fields by ~
    CONVERT @FM TO "~" IN R.AC.STMT.HANDOFF
    EB.Reports.setOData(R.DE.ADDRESS:">":R.AC.STMT.HANDOFF)
*
    Y.DATA = 'R.DE.ADDRESS=':R.DE.ADDRESS:'*':'R.AC.STMT.HANDOFF=':R.AC.STMT.HANDOFF
    Y.DIR = 'MBL.DATA'
    Y.FILE.NAME = 'AMC'
    OPENSEQ Y.DIR,Y.FILE.NAME TO F.DIR THEN NULL
    WRITESEQ Y.DATA APPEND TO F.DIR ELSE
        CRT "Unable to write"
        CLOSESEQ F.DIR
    END
RETURN
*-------------------------------------------------------------------------
INITIALISATION:
***************
    R.DE.ADDRESS = ''

    LOCATE "STATEMENT.ID" IN EB.Reports.getDFields()<1> SETTING STMT.POS ELSE
        STMT.POS = ""
    END

    IF EB.Reports.getDRangeAndValue()<STMT.POS> THEN                   ;* to process the enquiry of ACCOUNT.STATEMENT
        ACCOUNT.KEY = EB.Reports.getDRangeAndValue()<STMT.POS>[".",1,1]
        REQUESTED.DATE = EB.Reports.getDRangeAndValue()<STMT.POS>[".",2,1]
        FREQUENCY = EB.Reports.getDRangeAndValue()<STMT.POS>[".",3,1]
        CARRIER = EB.Reports.getDRangeAndValue()<STMT.POS>[".",4,1]
        PRINT.CUSTOMER = EB.Reports.getDRangeAndValue()<STMT.POS>[".",5,1]

    END ELSE
*
** Look for the account number and date and frequency to build the key
*
        LOCATE "SELECT.ACCOUNT" IN EB.Reports.getDFields()<1> SETTING YAC.POS THEN
            ACCOUNT.KEY = EB.Reports.getDRangeAndValue()<YAC.POS>
        END ELSE
            ACCOUNT.KEY = ""
        END
        LOCATE "STMT.DATE" IN EB.Reports.getDFields()<1> SETTING DATE.POS THEN
            REQUESTED.DATE = EB.Reports.getDRangeAndValue()<DATE.POS>
        END ELSE
            REQUESTED.DATE = ""
        END

        LOCATE "STMT.FREQ" IN EB.Reports.getDFields()<1> SETTING FREQ.POS THEN
            FREQUENCY = EB.Reports.getDRangeAndValue()<FREQ.POS>
        END ELSE
            FREQUENCY = 1
        END
        CARRIER = ""
    END

    FREQUENCY = FREQUENCY[";",1,1]      ;* Strip off end bit
    FREQUENCY = FREQUENCY[1,1]
*
    HVT = ''

    IF NOT(FREQUENCY) THEN
        FREQUENCY = 1         ;* Default
    END
*
    IF NOT(CARRIER) THEN
        CARRIER = 1 ;* Default
    END

    READ.HANDOFF.FLAG = ''    ;* This falg will be set while readding Already availbale Handoff Record.

RETURN
*
*-------------------------------------------------------------------------
GET.HANDOFF.RECORD:
*******************
* Read handoff record - if not on live try the history file
* The statement date is determined by locating in the ACCT.STMT.PRINT
* record. If the date supplied is beyond the current list then we need
* to supply a dummy handoff record back to the enquiry.  This enquiry
* can be used for printing/reprinting valid statements or for showing
* entries since the last statement.
*
    GOSUB GET.DATES
    IF STATEMENT.DATE AND REQUESTED.DATE THEN     ;* Valid date
        LANG = EB.SystemTables.getLngg() ;* Use passed setting from PRINT.STATENENTS
        HANDOFF.KEY = ACCOUNT.KEY:".":STATEMENT.DATE:".":FREQUENCY
* CI_10044210 S
* Attempt to read statement handoff record from live file then from
* history file. If is cannot be found, attempt to read the account
* closing record from live then history. If that fails too, build
* the handoff record.
        GOSUB READ.HANDOFF.RECORD
        IF R.AC.STMT.HANDOFF = "" THEN
            SAVE.HANDOFF.KEY = HANDOFF.KEY
            HANDOFF.KEY := "C"
            GOSUB READ.HANDOFF.RECORD
            IF R.AC.STMT.HANDOFF = "" THEN
                HANDOFF.KEY = SAVE.HANDOFF.KEY
                GOSUB BUILD.HANDOFF.RECORD
            END
        END
* CI_10044210 E
    END ELSE
        OPENING.BALANCE = ""
        GOSUB BUILD.HANDOFF.RECORD
        LANG = R.AC.STMT.HANDOFF<ST.AccountStatement.AcStmtHandoff.AcSthLanguage> ;* Use default  = customer
    END
*
RETURN
* CI_10044210 S
*-----------------------------------------------------------------------------
GET.DATES:
**********
*
    LOCATE "PROCESSING.DATE" IN EB.Reports.getDFields()<1> SETTING DATE.POS THEN
        OLD.REQ.DATE = REQUESTED.DATE   ;* Store date
        REQUESTED.DATE = RAISE(RAISE(EB.Reports.getDRangeAndValue()<DATE.POS>))
        DAT.CNT = DCOUNT(REQUESTED.DATE ,@FM)
        REQUESTED.DATE = REQUESTED.DATE<DAT.CNT>
        IF NOT(REQUESTED.DATE) THEN     ;* Reassign the old date when date is null
            REQUESTED.DATE = OLD.REQ.DATE
        END
    END ELSE
        REQUESTED.DATE = ""
    END

    AC.STMT.PRINT.ID = ACCOUNT.KEY
    IF FREQUENCY GT 2 THEN
        AC.STMT.PRINT.ID = ACCOUNT.KEY:'.':FREQUENCY
    END

    GOSUB READ.ASP.RECORD

    LOCATE REQUESTED.DATE IN R.ACCT.STMT.PRINT<1> BY "AL" SETTING POS ELSE
        NULL        ;* Look for statement date
    END
    STATEMENT.DATE = R.ACCT.STMT.PRINT<POS>["/",1,1]        ;* Remove closing balance bit
    PREVIOUS.STATEMENT.DATE = R.ACCT.STMT.PRINT<POS-1>["/",1,1]       ;* & one before
    OPENING.BALANCE = R.ACCT.STMT.PRINT<POS>["/",2,1]       ;* Could be null

RETURN
*------------------------------------------------------------------------------
READ.ASP.RECORD:
****************
*
    R.ACCOUNT = AC.AccountOpening.tableAccount(ACCOUNT.KEY, READ.ERR)
* Replaced the read for ACCT.STMT.PRINT with EB.READ.HVT common API whcih will check for HVT flag
* and return notionally merged record for HVT accounts otherwise return the record from disc.
    R.ACCT.STMT.PRINT = ''

* The Account Statement Print Id (AC.STMT.PRINT.ID) is to be populated while calling
* EB.READ.HVT instead of ACCOUNT.

    IF FREQUENCY[1,1] # "1" THEN
        AC.HighVolume.EbReadHvt('ACCT.STMT2.PRINT', AC.STMT.PRINT.ID, R.ACCT.STMT.PRINT, '')    ;* Call the core api to get the merged info for HVT accounts
    END ELSE
        AC.HighVolume.EbReadHvt('ACCT.STMT.PRINT', AC.STMT.PRINT.ID, R.ACCT.STMT.PRINT, '')     ;* Call the core api to get the merged info for HVT accounts
    END

RETURN
*-----------------------------------------------------------------------------
*** <region name= READ.HANDOFF.RECORD>
READ.HANDOFF.RECORD:
********************
*** <desc>Attempt to read handoff record from live, then history</desc>
    READ.ERR = ""


    R.AC.STMT.HANDOFF = ST.AccountStatement.AcStmtHandoff.Read(HANDOFF.KEY, READ.ERR)

    IF READ.ERR THEN

        R.AC.STMT.HANDOFF = ST.AccountStatement.AcStmtHandoff.ReadHis(HANDOFF.KEY:";1", Y.ERR)

        IF Y.ERR THEN
            R.AC.STMT.HANDOFF = ""
        END
    END

    IF R.AC.STMT.HANDOFF THEN
        READ.HANDOFF.FLAG = 1
        OPENING.DATE = R.AC.STMT.HANDOFF<ST.AccountStatement.AcStmtHandoff.AcSthOpeningDate>         ;* Last Frequency Date
        IF OPENING.DATE NE '' THEN
            EB.API.Cdt('' , OPENING.DATE ,'+1C')    ;* Add one calander date with Last Freq sate to get the next statement start date
        END
        R.AC.STMT.HANDOFF<ST.AccountStatement.AcStmtHandoff.AcSthOpeningDate> = OPENING.DATE         ;*Next Statement start date (Ex 30nov+1 cander day-01dec2000)
        GOSUB GET.TO.DATE
    END

RETURN
*** </region>
*---------------------------------------------------------------------------
GET.TO.DATE:
***********

    SYS.ID.IN = ''
    ANY.VD = ''     ;* 1 if any sys id has v.d. accounting set
    VD.SYS = ''     ;* 1 for value dated, 0 for trade dated

    AC.API.ValueDatedAcctng(SYS.ID.IN, '', '', '', ANY.VD, VD.SYS)
*
    IF READ.HANDOFF.FLAG THEN
        R.AC.STMT.HANDOFF<ST.AccountStatement.AcStmtHandoff.AcSthToDate> = REQUESTED.DATE  ;* While reading already available Handoff record TO.DATE should be the Last Frequency date
    END ELSE
        IF EB.SystemTables.getRAccountParameter()<AC.Config.AccountParameter.ParValueDatedAcctng>[1,1] NE "Y" AND NOT(ANY.VD) THEN          ;* if ANY.VD is set then TO.DATE is Period end date
            R.AC.STMT.HANDOFF<ST.AccountStatement.AcStmtHandoff.AcSthToDate> = EB.SystemTables.getToday()       ;* While building new Handoff record system should assign the TODAY value in TO.DATE field
        END ELSE
            R.AC.STMT.HANDOFF<ST.AccountStatement.AcStmtHandoff.AcSthToDate> = EB.SystemTables.getRDates(EB.Utility.Dates.DatPeriodEnd)      ;* For value dated accounting TO.DATE should be PERIOD.END datew
        END
    END

RETURN
*--------------------------------------------------------------------------
READ.ACCOUNT.STMT.RECORD:
************************
** Read the history file if it doesn't exists in live.
*
    READ.ERR = ""

    R.ACCOUNT.STATEMENT = ST.AccountStatement.AccountStatement.Read(ACCOUNT.KEY, READ.ERR)

    IF READ.ERR THEN
        AS.ID = ACCOUNT.KEY
        ST.AccountStatement.AccountStatementHistRead(AS.ID, AS.HIST.REC, AS.ERR)
        R.ACCOUNT.STATEMENT = AS.HIST.REC
        IF AS.ERR THEN
            tmp=EB.Reports.getEnqError(); tmp<-1>="Missing ACCOUNT.STATEMENT record ":ACCOUNT.KEY; EB.Reports.setEnqError(tmp)
            GOSUB PROGRAM.ABORT
        END
    END
*
RETURN
*--------------------------------------------------------------------------------------------------
BUILD.HANDOFF.RECORD:
*********************
*
* Date beyond printed statements - so this must be for an enquiry since the
* last statement. Build a dummy handoff record so the enquiry will still
* work.
*
    GOSUB READ.ACCOUNT.STMT.RECORD
    GOSUB GET.CUSTOMER.DETAILS
*
    R.AC.STMT.HANDOFF = ""
*
    R.AC.STMT.HANDOFF<ST.AccountStatement.AcStmtHandoff.AcSthCarrierAddrNo> = "PRINT.1"
    R.AC.STMT.HANDOFF<ST.AccountStatement.AcStmtHandoff.AcSthLanguage> = R.CUSTOMER<ST.Customer.Customer.EbCusLanguage>
    R.AC.STMT.HANDOFF<ST.AccountStatement.AcStmtHandoff.AcSthCustomer> = CustomerKey
    R.AC.STMT.HANDOFF<ST.AccountStatement.AcStmtHandoff.AcSthSectorCode> =  R.CUSTOMER<ST.Customer.Customer.EbCusSector>
    R.AC.STMT.HANDOFF<ST.AccountStatement.AcStmtHandoff.AcSthCompanyCode> = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComCustomerCompany)
    R.AC.STMT.HANDOFF<ST.AccountStatement.AcStmtHandoff.AcSthAccountOfficer> = R.ACCOUNT<AC.AccountOpening.Account.AccountOfficer>
    R.AC.STMT.HANDOFF<ST.AccountStatement.AcStmtHandoff.AcSthCurrency> = R.ACCOUNT<AC.AccountOpening.Account.Currency>
    R.AC.STMT.HANDOFF<ST.AccountStatement.AcStmtHandoff.AcSthAcctCategory> = R.ACCOUNT<AC.AccountOpening.Account.Category>
    R.AC.STMT.HANDOFF<ST.AccountStatement.AcStmtHandoff.AcSthAcctLimitRef> = R.ACCOUNT<AC.AccountOpening.Account.LimitRef>
    R.AC.STMT.HANDOFF<ST.AccountStatement.AcStmtHandoff.AcSthStatementNo> = R.ACCOUNT.STATEMENT<ST.AccountStatement.AccountStatement.AcStaLastStatementNo> + 1      ;* Next number
*
    IF PREVIOUS.STATEMENT.DATE THEN
        EB.API.Cdt('' , PREVIOUS.STATEMENT.DATE , '+1C')      ;* Add one calander date to get correct statement start date
        R.AC.STMT.HANDOFF<ST.AccountStatement.AcStmtHandoff.AcSthOpeningDate> = PREVIOUS.STATEMENT.DATE
    END ELSE
        R.AC.STMT.HANDOFF<ST.AccountStatement.AcStmtHandoff.AcSthOpeningDate> = R.ACCOUNT<AC.AccountOpening.Account.OpeningDate>
    END
*
    IF OPENING.BALANCE = '' THEN
        R.AC.STMT.HANDOFF<ST.AccountStatement.AcStmtHandoff.AcSthOpeningBalance> = R.ACCOUNT.STATEMENT<ST.AccountStatement.AccountStatement.AcStaFquOneLastBalance>   ;* Last bala/BAL nce on record
    END ELSE
        R.AC.STMT.HANDOFF<ST.AccountStatement.AcStmtHandoff.AcSthOpeningBalance> = OPENING.BALANCE
    END
    R.AC.STMT.HANDOFF<ST.AccountStatement.AcStmtHandoff.AcSthDescriptiveStmt> = R.ACCOUNT.STATEMENT<ST.AccountStatement.AccountStatement.AcStaDescriptStatement>
*
* Since frequency dates are multi valued get the nearest frequency
* date for processing.
    IF FREQUENCY = 1 THEN     ;* Frequency 1
        FQU.DATES = R.ACCOUNT.STATEMENT<ST.AccountStatement.AccountStatement.AcStaStmtFquOne>
    END ELSE        ;* Additional frequencies.
        LOCATE FREQUENCY IN R.ACCOUNT.STATEMENT<ST.AccountStatement.AccountStatement.AcStaFreqNo> SETTING FREQ.POS ELSE
            FREQ.POS = 0
        END
        FQU.DATES = R.ACCOUNT.STATEMENT<ST.AccountStatement.AccountStatement.AcStaStmtFquTwo,FREQ.POS>
        FQU.DATES = RAISE(FQU.DATES)
    END
    GOSUB GET.NEAR.FQU        ;* Get the nearest fqu to process.
    R.AC.STMT.HANDOFF<ST.AccountStatement.AcStmtHandoff.AcSthStmtFrequ> = LATEST.FQU[5]
*
    R.AC.STMT.HANDOFF<ST.AccountStatement.AcStmtHandoff.AcSthAcctTitleTwo> = R.ACCOUNT<AC.AccountOpening.Account.AccountTitleTwo>
    R.AC.STMT.HANDOFF<ST.AccountStatement.AcStmtHandoff.AcSthConditionGroup> = R.ACCOUNT<AC.AccountOpening.Account.ConditionGroup>
    R.AC.STMT.HANDOFF<ST.AccountStatement.AcStmtHandoff.AcSthShortTitle> = R.ACCOUNT<AC.AccountOpening.Account.ShortTitle>

    GOSUB GET.TO.DATE
*
RETURN
*-------------------------------------------------------------------------------------------------
GET.CUSTOMER.DETAILS:
*********************
*
    CustomerKey = R.ACCOUNT<AC.AccountOpening.Account.Customer>
    R.CUSTOMER = ''
    IF CustomerKey THEN
        READ.ERR = ""
        customerRecord = ''
        CALL CustomerService.getRecord(CustomerKey, customerRecord)
        IF NOT(customerRecord) THEN
            tmp=EB.Reports.getEnqError(); tmp<-1>="Missing CUSTOMER record ":CustomerKey; EB.Reports.setEnqError(tmp)
            GOSUB PROGRAM.ABORT
        END
        R.CUSTOMER = customerRecord
    END ELSE
        R.CUSTOMER<ST.Customer.Customer.EbCusLanguage> = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLanguageCode) ;* Use company for internal A/c
    END

RETURN
*-----------------------------------------------------------------------------------------------------
GET.NEAR.FQU:
*************
* Return the nearest frequency date for processing.
    LATEST.FQU = '' ; DATE.LIST = ''
    IF FQU.DATES THEN
        FQU.DATE.CNT = DCOUNT(FQU.DATES,@VM)
        IF FQU.DATE.CNT = 1 THEN        ;* If only one addl fqu exists.
            LATEST.FQU = FQU.DATES
        END ELSE
            FOR FDATE = 1 TO FQU.DATE.CNT
                DATE.LIST<-1> = FQU.DATES[1,8]    ;* Strip the date part.
            NEXT FDATE
            LATEST.DATE = MINIMUM(DATE.LIST) ;* Get the nearest date.

            LOCATE LATEST.DATE IN DATE.LIST<1> SETTING FDATE.POS ELSE
                FDATE.POS = 1
            END
            LATEST.FQU = DATE.LIST<1,FDATE.POS>   ;* Return nearest freq.
        END
    END
RETURN
*--------------------------------------------------------------------------------------------------
GET.ADDRESS:
************
* Determine the correct address from delivery, based on the carrier
* The company id (for the customer), the customer id & the carrier.
*
    INT.FLAG = ''
    AC.AccountOpening.IntAcc(ACCOUNT.KEY,INT.FLAG)
    IF INT.FLAG = 1 THEN
        RETURN
    END

    CARRIER.NAME = "PRINT.": CARRIER    ;* Ie PRINT.1
    IF PRINT.CUSTOMER THEN
        DE.ADDRESS.KEY= EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComCustomerCompany):".C-":PRINT.CUSTOMER:".":CARRIER.NAME
    END ELSE
        DE.ADDRESS.KEY= EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComCustomerCompany):".C-":R.AC.STMT.HANDOFF<ST.AccountStatement.AcStmtHandoff.AcSthCustomer>:".":CARRIER.NAME
    END
*
    READ.ERR = ""

    R.DE.ADDRESS = DE.Config.Address.Read(DE.ADDRESS.KEY, READ.ERR)

    IF READ.ERR THEN
        tmp=EB.Reports.getEnqError(); tmp<-1>="Missing DE.ADDRESS record ":DE.ADDRESS.KEY; EB.Reports.setEnqError(tmp)
    END
    FOR FIELD.NO = DE.Config.Address.AddBranchnameTitle TO DE.Config.Address.AddCountry
        TEMP.FLD = R.DE.ADDRESS<FIELD.NO>
        IF TEMP.FLD<1,LANG> THEN
            R.DE.ADDRESS<FIELD.NO> = TEMP.FLD<1,LANG>
        END ELSE
            R.DE.ADDRESS<FIELD.NO> = TEMP.FLD<1,1>
        END
    NEXT FIELD.NO
*
RETURN
*
*-------------------------------------------------------------------------
PROGRAM.ABORT:
* This should be the last para always and there should not be return statement so the program terminates here
*--------------------------------------------------------------------------------------------------

END
