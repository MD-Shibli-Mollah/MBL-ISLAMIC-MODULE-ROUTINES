$PACKAGE AA.Framework
SUBROUTINE GB.MBL.ONE.FORTH.BAL.RESTRICT(PROPERTY.ID, START.DATE, END.DATE, CURRENT.DATE, BALANCE.TYPE, ACTIVITY.IDS, CURRENT.VALUE, START.VALUE, END.VALUE)

* Subroutine Description:
* THIS ROUTINE FOR ON FORTH BALANCE RESTRIC
* DURING FT AND TF SETTLEMENT
* Subroutine Type:
* Attached To    : AA.PERIODIC.ATTRIBUTE.CLASS(ONE.FORTH.BALANCE)
* Attached As    :
*-----------------------------------------------------------------------------
* Modification History :
* 10/04/2020 -                            NEW   - Sarowar Mortoza
*                                                     FDS Pvt Ltd
*-----------------------------------------------------------------------------

*** <region name= Description>
*** <desc>Task of the sub-routine</desc>
* Program Description
* This is a RULE.VAL.RTN designed and released to evaluate the newly created
* Periodic Attribute Classes
*
*-----------------------------------------------------------------------------
* @uses I_AA.APP.COMMON
* @package retaillending.AA
* @stereotype subroutine
* @author carolbabu@temenos.com
*-----------------------------------------------------------------------------
*** </region>
**
*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
* Arguments
*
* Input
*
* @param Property ID   - Property ID
* @param Start Date    - Rule Start Date
* @param End Date      - Rule End Date
* @param Current Date  - The current date at which the arrangement is running and for which the balance amount is sought
* @param Balance Type  - Balance Type for which the Balance Amount is required
* @param Activity ID   - Activity ID for which the Balance Amount is required
*
* Ouptut
* @return Current Value - The value for the attribute on the actual date.
* @return Start Value   - Balance Amounts of the Authorised Movements
* @return End Value     - Balance Amounts of all the Movements
*
*** </region>

*-----------------------------------------------------------------------------

*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine</desc>
* Modification History
*
* 24/11/10 - EN_72965
*            New routine to get the balance amount
*            used in rule evaluation
*
* 19/02/11 - EN_56307
*            Task: 136334
*            Locate statement added to locate the Balance amount in the end date
*
* 10/03/11 - 159892
*            Ref: 56308
*            Balance amount should not be absolute since for Accounts PL balance
*            can be negative or positive
*
* 05/04/11 - Task: 185974
*            Defect: 183878
*            Code changes to include the Current activity amount with the END.VALUE
*
* 13/04/11 - Task : 191239
*            Defect : 183803
*            Code changes to avail current balances without locating effective date.
*
* 25/06/11 - Task: 233604
*            Defect: 232907
*            If start date and end date is equal then set start value to zero. On same
*            date it is not required to know start value.
*
* 28/06/11 - Task : 235280
*            Defect : 232743
*            Dont blindly add the TXN amount for ACCOUNTs. DIRECT.ACCOUNTING changes have already updated
*            the balances correctly. So, dont add the amounts - it would double it.
*
* 31/10/13 - Task : 825041
*          - Defect : 799787
*          - If settlement instruction are given inside AA, negative amount is passed as END.VALUE
*
* 29/11/14 - 1184118
*            Ref: 1183050
*            Do not set DIRECT.ACCTNG for activities that doesn't raise direct accounting
*
* 04/12/14 - Task : 1188606
*            Defect : 1184404
*            Current balance goes below the specified value because of the current transaction amount included
*
* 29/11/14 - Defect:1183050
*            Ref: 1225357
*            We need too loop through all balances if the balance type is "VIRTUAL"
*** </region>

*-----------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>
* Inserts
    $USING AC.BalanceUpdates
    $USING AC.SoftAccounting
    $USING AA.Framework

*** </region>

*-----------------------------------------------------------------------------

*** <region name= Main control>
*** <desc>main control logic in the sub-routine</desc>

    GOSUB INITIALISE
    GOSUB GET.REAL.BALANCE.TYPE   ;* Check virtual balance type.
    GOSUB PROCESS                 ;* Find balance amount for the dates

RETURN

*-----------------------------------------------------------------------------

*** <region name= Initialise>
*** <desc>Initialise para in the sub routine</desc>
INITIALISE:

    CHECK.END.DATE = END.DATE        ;* Required end date
    CHECK.START.DATE = ''
    CHECK.START.DATE = START.DATE    ;* Required start date
    INITIAL.AVAIL.BAL = ''
    START.VALUE = 0
    END.VALUE = 0
    BALANCE.TYPE.LIST = '' ;* List of balance to evaluate.
    
***********
    TXN.AMOUNT = AA.Framework.getRArrangementActivity()<AA.Framework.ArrangementActivity.ArrActTxnAmount>

RETURN

*-----------------------------------------------------------------------------

*** <region name= Get Real Balance Type>
*** <desc>If the given balance is a VIRTUAL balance then we need to load the real balance </desc>
GET.REAL.BALANCE.TYPE:

    BALANCE.TYPE.LIST = BALANCE.TYPE

    R.BALANCE.TYPE = ''
    R.BALANCE.TYPE = AC.SoftAccounting.BalanceType.CacheRead(BALANCE.TYPE.LIST, VAL.ERR)
    IF R.BALANCE.TYPE<AC.SoftAccounting.BalanceType.BtReportingType> = "VIRTUAL" THEN  ;* I am not a real balance
        BALANCE.TYPE.LIST = R.BALANCE.TYPE<AC.SoftAccounting.BalanceType.BtVirtualBal> ;* Load real balance
    END

RETURN

*** <region name= Process>
*** <desc>Process para in the subroutine</desc>
PROCESS:

    BALANCE.COUNT = 1             ;* Balance count
    BALANCE.TOT = DCOUNT(BALANCE.TYPE.LIST,@VM) ;* Total number of balances

    LOOP
    WHILE BALANCE.COUNT LE BALANCE.TOT
        BALANCE.NAME = BALANCE.TYPE.LIST<1,BALANCE.COUNT>   ;* Current balance type

*** Find start balance
        IF CHECK.START.DATE NE CHECK.END.DATE THEN  ;* No need to find start balance when start date and end date are same
            CHECK.DATE = CHECK.START.DATE
            GOSUB GET.BALANCE.AMOUNT                ;* Get the amount for this balance name & start date
            START.VALUE += BALANCE.AMOUNT           ;* Add the amounts
       
***********************************************************
            START.VALUE = (TXN.AMOUNT * 100) / START.VALUE
***********************************************************
        END

*** Find end balance
        CHECK.DATE = CHECK.END.DATE
        GOSUB GET.BALANCE.AMOUNT               ;* Get the amount for this balance name & end date
        END.VALUE += BALANCE.AMOUNT            ;* Add the amounts
*************************************************
        END.VALUE = BALANCE.AMOUNT + TXN.AMOUNT
        END.VALUE = (TXN.AMOUNT * 100) / END.VALUE
*************************************************
        BALANCE.COUNT ++
    REPEAT
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Get Balance Amount>
*** <desc>Get balance amount for this balance name</desc>
GET.BALANCE.AMOUNT:

    ERR.MSG = ''
    BAL.DETAILS = ''          ;* The current balance figure
    DATE.OPTIONS = ""
    DATE.OPTIONS<2> = "ALL"   ;* Include all unauthorised movements
    ACCOUNT.ID = AA.Framework.getLinkedAccount()
    BALANCE.AMOUNT = 0

    AA.Framework.GetPeriodBalances(ACCOUNT.ID, BALANCE.NAME, DATE.OPTIONS, CHECK.DATE, "", "", BAL.DETAILS, ERR.MSG)

    IF BAL.DETAILS<AC.BalanceUpdates.AcctActivity.IcActBalance> THEN
        BALANCE.AMOUNT = BAL.DETAILS<AC.BalanceUpdates.AcctActivity.IcActBalance> ;* Add only having balance.
    END

RETURN

END
