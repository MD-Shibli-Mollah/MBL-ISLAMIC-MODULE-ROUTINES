SUBROUTINE GB.MBL.A.CUS.CALL.WRITE
*-----------------------------------------------------------------------------
*Subroutine Description: This routine is use for customer cell no in local tempalte MBL.CUS.CALL.CENTRE
*Subroutine Type:
*Attached To    : Customer Version (CUSTOMER,MBL.INDV)
*Attached As    : Auth ROUTINE
*TAFC Routine Name :CUS.CALL.WRITE.AUTH
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
    $INSERT I_F.MBL.CUS.CALL.CENTRE
    GOSUB INITIALISE ; *INITIALIZATION
    GOSUB OPENFILE ; *FILE OPEN
    GOSUB PROCESS ; *BUSINESS LOGIC PROCESS
*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>INITIALIZATION </desc>
    !DEBUG
    FN.CUS = 'F.CUSTOMER'
    F.CUS  = ''
    FN.CUS.CALL = 'F.MBL.CUS.CALL.CENTRE'
    F.CUS.CALL = ''
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= OPENFILE>
OPENFILE:
*** <desc>FILE OPEN </desc>
    EB.DataAccess.Opf(FN.CUS,F.CUS)
    EB.DataAccess.Opf(FN.CUS.CALL,F.CUS.CALL)
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc>BUSINESS LOGIC PROCESS </desc>
    IF EB.SystemTables.getVFunction() EQ 'A' THEN
        Y.CUS.ID = EB.SystemTables.getIdNew()
        Y.CELL.NEW=EB.SystemTables.getRNew(ST.Customer.Customer.EbCusSmsOne)
        EB.DataAccess.FRead(FN.CUS,Y.CUS.ID,REC.CUS,F.CUS,ERR.CUS)
        Y.CELL.OLD =REC.CUS<ST.Customer.Customer.EbCusSmsOne>
        IF REC.CUS THEN
            EB.DataAccess.FRead(FN.CUS.CALL,Y.CELL.OLD,REC.CUS.CALL,F.CUS.CALL,ERR.CUS.CALL)
            IF REC.CUS.CALL THEN
                IF Y.CELL.NEW EQ Y.CELL.OLD  THEN
                    RETURN
                END
                ELSE
                    DELETE F.CUS.CALL,Y.CELL.OLD
                END
            END
        END
        REC.CUS.CALL<CALL.CENTRE.CUS.ID> = Y.CUS.ID
        WRITE REC.CUS.CALL TO F.CUS.CALL,Y.CELL.NEW
    END
RETURN
*** </region>

END



