* @ValidationCode : Mjo1MzYxODEwMTQ6Q3AxMjUyOjE1OTI3Mzk2NTM4MTk6dXNlcjotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 21 Jun 2020 17:40:53
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : user
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
PROGRAM GB.MBL.V.SAVINGS.DEP.SCH
*Subroutine Description: Automating Monthly savings scheme schedule
*Subroutine Type : Pre Validation Routine(API)
*Attached To : Activity API
*Attached As : Pre Validation Routine
*Developed by : Md Golam Rased
*Designation : Technical Consultant
*Email : md.rased@fortress-global.com
*Incoming Parameters :
*Outgoing Parameters :
*-----------------------------------------------------------------------------
* Modification History :
* 1)
* Date :
* Modification Description :
* Modified By :
*
*-----------------------------------------------------------------------------
*
*1/S----Modification Start
*
*1/E----Modification End
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    
    $USING EB.SystemTables
    $USING AA.Framework
    $USING AA.PaymentSchedule
    $USING AA.TermAmount
    $USING EB.Utility
*-----------------------------------------------------------------------------

    ArrangementId = c_aalocArrId
    PropertyClass = 'TERM.AMOUNT'
    NoOfInstallment = ''
    Amount = ''
    
    AA.Framework.GetArrangementConditions(ArrangementId, PropertyClass, Property, '', ReturnIds, ReturnValues, ErrorMsg)
    CommitmentData = RAISE(ReturnValues)

    Amount = CommitmentData<AA.TermAmount.TermAmount.AmtAmount>
    Term = CommitmentData<AA.TermAmount.TermAmount.AmtTerm>
    EffectiveDate = c_aalocActivityEffDate

    IF RIGHT(Term,1) EQ 'Y' THEN
        NoOfInstallment = (Term[1,LEN(Term)-1] * 12) -1
    END
    IF RIGHT(Term,1) EQ 'M' THEN
        NoOfInstallment = Term[1,LEN(Term)-1] - 1
    END
    
    NumPayments = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsNumPayments)
    StartDate = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsStartDate)
    ActualAmt = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsActualAmt)
    PaymentType = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)
    
    LOCATE 'DEPOSIT.SAVINGS' IN PaymentType<1,1> SETTING POS THEN
        NumPayments<1,POS> = NoOfInstallment
        ActualAmt<1,POS> = Amount
        IF RIGHT(EffectiveDate,2) LT 10 THEN
            Temp = '1M'
            EB.Utility.CalendarDay(EffectiveDate, '+', Temp)
            StartDate<1,POS> = 'D_' : Temp[1,LEN(Temp)-2] : '10'
            EB.SystemTables.setRNew(AA.PaymentSchedule.PaymentSchedule.PsStartDate, StartDate)
        END
        EB.SystemTables.setRNew(AA.PaymentSchedule.PaymentSchedule.PsNumPayments, NumPayments)
        EB.SystemTables.setRNew(AA.PaymentSchedule.PaymentSchedule.PsActualAmt, ActualAmt)
    END
RETURN
END
