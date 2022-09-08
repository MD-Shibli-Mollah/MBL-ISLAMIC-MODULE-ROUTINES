SUBROUTINE GB.MBL.I.CUS.CORP
*-----------------------------------------------------------------------------
*Subroutine Description: This routine use for corporta customer validation like legal document, KYC
*Subroutine Type:
*Attached To    : Customer Version (CUSTOMER,BD.CORP)
*Attached As    : INPUT ROUTINE
*TAFC Routine Name :BD.CUS.CORP
*-----------------------------------------------------------------------------
* Modification History :
* 01/10/2019 -                            Retrofit   - Sarowar Mortoza
*                                                     FDS Pvt Ltd
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING ST.Customer
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING EB.ErrorProcessing
    $USING EB.Foundation
    $USING EB.Utility
*-----------------------------------------------------------------------------
    GOSUB INITIALISE ; *INITIALISATION
    GOSUB OPENFILE ; *FILE OPEN
    GOSUB PROCESS ; *PROCESS BUSINESS LOGIC
*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>INITIALISATION </desc>
    FN.CUSTOMER = "F.CUSTOMER"
    F.CUSTOMER = ""
    Y.NAME.1 = ''
    Y.NAME.2 = ''
    Y.NULL = ''
    Y.LEGAL.DOC.NAME = ''
    Y.LEGAL.DOC.NAME.CHK=''
    Y.TODAY = EB.SystemTables.getToday()
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= OPENFILE>
OPENFILE:
*** <desc>FILE OPEN </desc>
    EB.DataAccess.Opf(FN.CUSTOMER, F.CUSTOMER)
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc>PROCESS BUSINESS LOGIC </desc>
    GOSUB GET.LOC.REF ; *GET LOCAL REFERENCE FIELD
    Y.LEGAL.DOC.NAME = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusLegalDocName)
    Y.DATE.OF.BIRTH = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusDateOfBirth)
    
    Y.POL.EX.PERSON = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusLocalRef)<1,Y.POLL.EXP.PERSON.POS>
    Y.SEN.MGT.APPR = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusLocalRef)<1,Y.SEN.MGT.APPR.POS>
    Y.SRC.WEALTH = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusLocalRef)<1,Y.CUS.SR.WELTH.POS>
    Y.INTERVIEW.PER = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusLocalRef)<1,Y.CUS.INTERVIWER.POS>
    Y.CUS.AD.VER = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusLocalRef)<1,Y.CUS.AD.VER.POS>
    Y.CUS.AD.V.DET = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusLocalRef)<1,Y.CUS.AD.V.DET.POS>
   
    Y.DATE.INCORP = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusBirthIncorpDate)
    Y.NAME.1 =  EB.SystemTables.getRNew(ST.Customer.Customer.EbCusShortName)<1,1>
    EB.SystemTables.setRNew(ST.Customer.Customer.EbCusNameOne,Y.NAME.1)
    Y.NAME.2 =  EB.SystemTables.getRNew(ST.Customer.Customer.EbCusShortName)<1,2>
    EB.SystemTables.setRNew(ST.Customer.Customer.EbCusNameTwo,Y.NAME.2)
    
    ARRAY = "NATIONAL.ID*PASSPORT*DRIVING.LICENCE*VOTER.ID.CARD*EMPLOYER.CERTIFICATE*BIRTH.CERT"

*****************************
    !Date of Incorporation Check:
*****************************

    IF Y.DATE.INCORP GT Y.TODAY THEN
        EB.SystemTables.setAf(ST.Customer.Customer.EbCusBirthIncorpDate)
        EB.SystemTables.setEtext("Date of Incorporation is Future Date")
        EB.ErrorProcessing.StoreEndError()
    END

**********************
    !Legal Document Check:
**********************

    IF INDEX(ARRAY,Y.LEGAL.DOC.NAME,1) THEN
        EB.SystemTables.setAf(ST.Customer.Customer.EbCusLegalIdDocName)
        EB.SystemTables.setEtext("Invalid Document For Corporate Customer")
        EB.ErrorProcessing.StoreEndError()
        RETURN
    END


*************************
    !Trade License Mandatory:
*************************

    Y.LEGAL.DOC.NAME.CNT = DCOUNT(Y.LEGAL.DOC.NAME,@VM)

    FOR I = 1 TO Y.LEGAL.DOC.NAME.CNT

        Y.LEGAL.DOC.NAME.NEW = Y.LEGAL.DOC.NAME<1,I>

        IF Y.LEGAL.DOC.NAME.NEW EQ "TRADE.LICENCE" THEN
            Y.LEGAL.DOC.NAME.CHK = Y.LEGAL.DOC.NAME.NEW
        END

    NEXT I

    IF Y.LEGAL.DOC.NAME.CHK NE "TRADE.LICENCE" THEN
        EB.SystemTables.setAf(ST.Customer.Customer.EbCusLegalIdDocName)
        EB.SystemTables.setEtext("Trade Licence is Mandatory for Corporate Customer !!")
        EB.ErrorProcessing.StoreEndError()
    END


*************************
    !Multi-Value SMS.1 Check:
*************************

    Y.SMS.NO = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusSmsOne)
    Y.SMS.NO.CNT = DCOUNT(Y.SMS.NO,@VM)

    IF Y.SMS.NO.CNT GT 1 THEN
        EB.SystemTables.setAf(ST.Customer.Customer.EbCusSmsOne)
        EB.SystemTables.setEtext("Only One Mobile Number is Allowed for SMS !!")
        EB.ErrorProcessing.StoreEndError()
    END

***********************************
    !Address: STREET.1 Field Mandatory:
***********************************
    Y.PRESENT.ADD = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusStreet)<1,1>

    IF Y.PRESENT.ADD EQ '' THEN
        EB.SystemTables.setAf(ST.Customer.Customer.EbCusStreet)
        EB.SystemTables.setAv(Y.PRESENT.ADD)
        EB.SystemTables.setEtext("Business/Office Address Line-1 is Mandatory")
        EB.ErrorProcessing.StoreEndError()
    END

*******************
    !KYC Details Check:
*******************
    IF Y.CUS.AD.VER EQ 'YES' THEN
        IF Y.CUS.AD.V.DET EQ Y.NULL THEN
            EB.SystemTables.setAf(ST.Customer.Customer.EbCusLocalRef)
            EB.SystemTables.setAv(Y.CUS.AD.V.DET.POS)
            EB.SystemTables.setEtext("Enter How Add Verified ")
            EB.ErrorProcessing.StoreEndError()
        END
    END

    IF Y.POL.EX.PERSON EQ "YES" THEN
        IF Y.SEN.MGT.APPR EQ Y.NULL THEN
            EB.SystemTables.setAf(ST.Customer.Customer.EbCusLocalRef)
            EB.SystemTables.setAv(Y.SEN.MGT.APPR.POS)
            EB.SystemTables.setEtext("Enter Approval")
            EB.ErrorProcessing.StoreEndError()
        END
        IF Y.SRC.WEALTH EQ Y.NULL THEN
            EB.SystemTables.setAf(ST.Customer.Customer.EbCusLocalRef)
            EB.SystemTables.setAv(Y.CUS.SR.WELTH.POS)
            EB.SystemTables.setEtext("Enter Source")
            EB.ErrorProcessing.StoreEndError()
        END
        IF Y.INTERVIEW.PER EQ Y.NULL THEN
            EB.SystemTables.setAf(ST.Customer.Customer.EbCusLocalRef)
            EB.SystemTables.setAv(Y.CUS.INTERVIWER.POS)
            EB.SystemTables.setEtext("Enter Interviewed Personally")
            EB.ErrorProcessing.StoreEndError()
        END
    END
RETURN

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GET.LOC.REF>
GET.LOC.REF:
*** <desc>GET LOCAL REFERENCE FIELD </desc>
    Y.POLL.EXP.PERSON.POS=''
    Y.SEN.MGT.APPR.POS=''
    Y.CUS.SR.WELTH.POS=''
    Y.CUS.INTERVIWER.POS=''
    Y.CUS.AD.VER.POS=""
    Y.CUS.AD.V.DET.POS=""
    Y.APP = "CUSTOMER"
    FLD.POS = ""
    LOCAL.FIELDS = ""
    LOCAL.FIELDS = "LT.CUS.P.EXPRSN":@VM:"LT.CUS.SR.M.APR":@VM:"LT.CUS.SR.WELTH":@VM:"LT.CUS.INT.PER":@VM:"LT.CUS.AD.VER":@VM:"LT.CUS.AD.V.DET"
    EB.Foundation.MapLocalFields(Y.APP, LOCAL.FIELDS, FLD.POS)
    Y.POLL.EXP.PERSON.POS=FLD.POS<1,1>
    Y.SEN.MGT.APPR.POS=FLD.POS<1,2>
    Y.CUS.SR.WELTH.POS=FLD.POS<1,3>
    Y.CUS.INTERVIWER.POS=FLD.POS<1,4>
    Y.CUS.AD.VER.POS=FLD.POS<1,5>
    Y.CUS.AD.V.DET.POS=FLD.POS<1,6>
RETURN
*** </region>

END
