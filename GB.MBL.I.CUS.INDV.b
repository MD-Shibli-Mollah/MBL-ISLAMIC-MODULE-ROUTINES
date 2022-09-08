* @ValidationCode : MjoxNzQ4ODg2ODQzOkNwMTI1MjoxNTY5OTIwNDMxMjI2Ok1PUlRPWkE6LTE6LTE6MDowOmZhbHNlOk4vQTpSMTlfU1AzLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 01 Oct 2019 15:00:31
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : MORTOZA
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R19_SP3.0
SUBROUTINE GB.MBL.I.CUS.INDV
*-----------------------------------------------------------------------------
*Subroutine Description:
** This routine is used for individaul customer validation like minor date of birth, KYC etc.
*Subroutine Type:
*Attached To    : Customer Version (CUSTOMER,MBL.INDV)
*Attached As    : INPUT ROUTINE
*TAFC Routine Name :BD.CUS.INDV
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
    Y.MINOR.DATE = ''
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
    Y.DOB = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusDateOfBirth)
    
    Y.GUARDIAN.NAME = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusLocalRef)<1,Y.GURDIAN.NAME.POS>
    Y.GUARDIAN.REL = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusLocalRef)<1,Y.GURDIAN.REL.POS>
    Y.POL.EX.PERSON = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusLocalRef)<1,Y.POLL.EXP.PERSON.POS>
    Y.SEN.MGT.APPR = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusLocalRef)<1,Y.SEN.MGT.APPR.POS>
    Y.SRC.WEALTH = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusLocalRef)<1,Y.CUS.SR.WELTH.POS>
    Y.INTERVIEW.PER = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusLocalRef)<1,Y.CUS.INTERVIWER.POS>
    Y.NID = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusLocalRef)<1,Y.CUS.NID.POS>
    Y.PP.NO = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusLocalRef)<1,Y.CUS.PP.POS>
    Y.BIRTH.CERTIFICATE = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusLocalRef)<1,Y.CUS.BR.POS>
    Y.DRV.LICENSE = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusLocalRef)<1,Y.CUS.DRV.POS>
    Y.CUS.AD.VER = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusLocalRef)<1,Y.CUS.AD.VER.POS>
    Y.CUS.AD.V.DET = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusLocalRef)<1,Y.CUS.AD.V.DET.POS>

    Y.NAME.1 =  EB.SystemTables.getRNew(ST.Customer.Customer.EbCusShortName)<1,1>
    EB.SystemTables.setRNew(ST.Customer.Customer.EbCusNameOne,Y.NAME.1)
    Y.NAME.2 =  EB.SystemTables.getRNew(ST.Customer.Customer.EbCusShortName)<1,2>
    EB.SystemTables.setRNew(ST.Customer.Customer.EbCusNameTwo,Y.NAME.2)
    
***********************************
    !Address: STREET.1 Field Mandatory:
***********************************

    Y.PRESENT.ADD = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusStreet)<1,1>
    IF Y.PRESENT.ADD EQ '' THEN
        EB.SystemTables.setAf(ST.Customer.Customer.EbCusStreet)
        EB.SystemTables.setAv(Y.PRESENT.ADD)
        EB.SystemTables.setEtext("Present Address Line-1 is Mandatory")
        EB.ErrorProcessing.StoreEndError()
    END
    
******************
    !Minor Date Check:
******************
    Y.MINOR.DATE = "18Y"
    EB.Utility.CalendarDay(Y.TODAY,'-',Y.MINOR.DATE)
    IF Y.DATE.OF.BIRTH LT Y.MINOR.DATE THEN
        T.LOCREF<Y.GURDIAN.NAME.POS,7> = "NOINPUT"
        T.LOCREF<Y.GURDIAN.REL.POS,7> = "NOINPUT"
    END

    IF Y.DOB GT Y.MINOR.DATE THEN
        IF Y.GUARDIAN.NAME EQ Y.NULL THEN
            EB.SystemTables.setAf(ST.Customer.Customer.EbCusLocalRef)
            EB.SystemTables.setAv(Y.GURDIAN.NAME.POS)
            EB.SystemTables.setEtext("Enter Name of Guardian")
            EB.ErrorProcessing.StoreEndError()
        END
        IF Y.GUARDIAN.REL EQ Y.NULL THEN
            EB.SystemTables.setAf(ST.Customer.Customer.EbCusLocalRef)
            EB.SystemTables.setAv(Y.GURDIAN.REL.POS)
            EB.SystemTables.setEtext("Enter Relation of Guardian")
            EB.ErrorProcessing.StoreEndError()
        END
        IF Y.DOB GT Y.TODAY THEN
            EB.SystemTables.setAf(ST.Customer.Customer.EbCusDateOfBirth)
            EB.SystemTables.setEtext("Date of birth is future date")
            EB.ErrorProcessing.StoreEndError()
        END
    END
         
    IF Y.NID EQ "" AND Y.PP.NO EQ "" AND Y.BIRTH.CERTIFICATE EQ "" AND Y.DRV.LICENSE EQ "" THEN
        EB.SystemTables.setEtext("Must be Fillup any one field of National Id, Passport No, Brith Certificate or Driving License ")
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
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GET.LOC.REF>
GET.LOC.REF:
*** <desc>GET LOCAL REFERENCE FIELD </desc>
    Y.GURDIAN.NAME.POS=''
    Y.GURDIAN.REL.POS=''
    Y.POLL.EXP.PERSON.POS=''
    Y.SEN.MGT.APPR.POS=''
    Y.CUS.SR.WELTH.POS=''
    Y.CUS.INTERVIWER.POS=''
    Y.CUS.NID.POS=""
    Y.CUS.PP.POS=""
    Y.CUS.BR.POS=""
    Y.CUS.DRV.POS=""
    Y.CUS.AD.VER.POS=""
    Y.CUS.AD.V.DET.POS=""
    Y.APP = "CUSTOMER"
    FLD.POS = ""
    LOCAL.FIELDS = ""
    LOCAL.FIELDS = "LT.CUS.GU.NAME":@VM:"LT.CUS.GU.REL":@VM:"LT.CUS.P.EXPRSN":@VM:"LT.CUS.SR.M.APR":@VM:"LT.CUS.SR.WELTH":@VM:"LT.CUS.INT.PER":@VM:"LT.CUS.NID":@VM:"LT.CUS.PP.NO":@VM:"LT.CUS.BR.CER":@VM:"LT.CUS.DRV.LIC":@VM:"LT.CUS.AD.VER":@VM:"LT.CUS.AD.V.DET"
    EB.Foundation.MapLocalFields(Y.APP, LOCAL.FIELDS, FLD.POS)
    Y.GURDIAN.NAME.POS=FLD.POS<1,1>
    Y.GURDIAN.REL.POS=FLD.POS<1,2>
    Y.POLL.EXP.PERSON.POS=FLD.POS<1,3>
    Y.SEN.MGT.APPR.POS=FLD.POS<1,4>
    Y.CUS.SR.WELTH.POS=FLD.POS<1,5>
    Y.CUS.INTERVIWER.POS=FLD.POS<1,6>
    Y.CUS.NID.POS=FLD.POS<1,7>
    Y.CUS.PP.POS=FLD.POS<1,8>
    Y.CUS.BR.POS=FLD.POS<1,9>
    Y.CUS.DRV.POS=FLD.POS<1,10>
    Y.CUS.AD.VER.POS=FLD.POS<1,11>
    Y.CUS.AD.V.DET.POS=FLD.POS<1,12>
RETURN
*** </region>

END




