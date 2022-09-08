SUBROUTINE GB.MBL.I.CCY.CHECK
*-----------------------------------------------------------------------------
**Subroutine Description:
** This routine is used for US-UN-EU Sanction high risk error
*Subroutine Type:
*Attached To    : Customer Version (CUSTOMER,MBL.INDV)
*Attached As    : INPUT ROTINE
*-----------------------------------------------------------------------------
* Modification History :
* 01/10/2019 -                            Retrofit   - Sarowar Mortoza
*                                                     FDS Pvt Ltd
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING ST.Customer
    $USING ST.Config
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING EB.ErrorProcessing
*-----------------------------------------------------------------------------
    GOSUB INITIALISE ; *INITIALISATION
    GOSUB OPENFILE ; *FILE OPNENING
    GOSUB PROCESS ; *BUSINESS LOGIC PROCESS
RETURN
*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>INITIALISATION </desc>
    FN.CUSTOMER = "F.CUSTOMER"
    F.CUSTOMER = ""
    FN.COUNTRY = "F.COUNTRY"
    F.COUNTRY = ''
    Y.CUS.ID = ''
    Y.CUS.ID = EB.SystemTables.getIdNew()
    
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= OPENFILE>
OPENFILE:
*** <desc>FILE OPNENING </desc>
    EB.DataAccess.Opf(FN.CUSTOMER, F.CUSTOMER)
    EB.DataAccess.Opf(FN.COUNTRY, F.COUNTRY)
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc>BUSINESS LOGIC PROCESS </desc>
    EB.DataAccess.FRead(FN.CUSTOMER,Y.CUS.ID,R.CUS.REC,F.CUSTOMER,Y.ERR)
    Y.COUNTRY = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusCountry)

    EB.DataAccess.FRead(FN.COUNTRY,Y.COUNTRY,R.CO.COUNTRY,F.COUNTRY,Y.ERRR)
    Y.HIGH.RISK = R.CO.COUNTRY<ST.Config.Country.EbCouHighRisk>
    IF Y.HIGH.RISK EQ "YES" THEN
        EB.SystemTables.setAf(ST.Customer.Customer.EbCusCountry)
        EB.SystemTables.setEtext("GB Country is Under US-UN-EU Sanction")
        EB.ErrorProcessing.StoreEndError()
    END
RETURN
*** </region>

END



