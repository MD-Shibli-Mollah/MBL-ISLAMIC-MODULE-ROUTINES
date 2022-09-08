SUBROUTINE GB.MBL.TT.FT.GL.PL.VALIDATE.RTN
*-----------------------------------------------------------------------------
* Subroutine Description:
* This routine will check that if logged in user is allowed to debit GL/PL
* account or not.
* Subroutine Type:
* Attached To    : EB.GC.CONSTRAINTS
* Attached As    :
*-----------------------------------------------------------------------------
* Modification History :
* R10 EXISTING RTN NAME V.TT.FT.GL.PL.VALIDATE.RTN
* 08/04/202020 -                            RETROFIT   - Sarowar Mortoza
*                                                 FDS Pvt Ltd
*-----------------------------------------------------------------------------
    $INSERT  I_COMMON
    $INSERT  I_EQUATE
    $INSERT  I_GTS.COMMON
    $USING  EB.Interface
    $USING  ST.CompanyCreation
    $USING  EB.Security
    $USING  FT.Contract
    $USING  TT.Contract
    $USING  AC.AccountOpening
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.ErrorProcessing
    $USING EB.Foundation
*-----------------------------------------------------------------------------
    GOSUB INITIALISE ; *
    GOSUB OPENFILES ; *
    GOSUB FT.PROCESS ; *
    GOSUB TT.PROCESS ; *
RETURN
*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc> </desc>
    Y.APPLICATION = EB.SystemTables.getApplication()
    Y.USER.ID = EB.SystemTables.getOperator()

    Y.DR.AC=""
    Y.CR.AC=""
    Y.CR.AC.TEST=""
    Y.DR.EXP=""
    Y.CR.EXP=""

    REC.AC.DR=""
    REC.AC.CR=""
    R.USR.REC=""
    Y.DR.CATEGORY.EXP.LIST=""
    Y.CR.CATEGORY.EXP.LIST=""

    Y.DR.AC.COMP=""
    Y.CR.AC.COMP=""

    Y.OWN.GL.FLG = ''
    Y.PL.FLG = ''
    Y.OTHER.PL.FLG = ''
    Y.OTHER.GL.FLG = ''

    Y.DELIM = '...\...'

    !Y.DR.CO.CODE = Y.DR.AC[13,4]
    ! Y.USER.CO.COMP = ID.COMPANY[6,4]
    Y.USER.CO.COMP = EB.SystemTables.getIdCompany()

    FN.USR='F.USER'
    F.USR=''

    FN.FT='F.FUNDS.TRANSFER'
    F.FT=''

    FN.TT='F.TELLER'
    F.TT=''

    FN.TID='F.TELLER.ID'
    F.TID=''

    FN.AC="F.ACCOUNT"
    F.AC=""
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= OPENFILES>
OPENFILES:
*** <desc> </desc>
    EB.DataAccess.Opf(FN.USR,F.USR)
    EB.DataAccess.Opf(FN.FT,F.FT)
    EB.DataAccess.Opf(FN.TT,F.TT)
    EB.DataAccess.Opf(FN.TID,F.TID)
    EB.DataAccess.Opf(FN.AC,F.AC)
    
    Y.USR.OWN.GL.POS=""
    Y.USR.OWN.PL.POS=""
    Y.USR.OTHER.GL.POS=""
    Y.USR.OTHER.PL.POS=""
    Y.USR.OWN.GLCR.POS=""
    Y.USR.OWN.PLCR.POS=""
    Y.USR.OTH.GLCR.POS=""
    Y.USR.OTH.PLCR.POS=""
    Y.APP = "USER"
    FLD.POS = ""
    LOCAL.FIELDS = ""
    LOCAL.FIELDS = "LT.USR.OWN.GL":@VM:"LT.USR.OWN.PL":@VM:"LT.USR.OTHER.GL":@VM:"LT.USR.OTHER.PL":@VM:"LT.USR.OWN.GLCR":@VM:"LT.USR.OWN.PLCR":@VM:"LT.USR.OTH.GLCR":@VM:"LT.USR.OTH.PLCR"
    EB.Foundation.MapLocalFields(Y.APP, LOCAL.FIELDS, FLD.POS)
    Y.USR.OWN.GL.POS=FLD.POS<1,1>
    Y.USR.OWN.PL.POS=FLD.POS<1,2>
    Y.USR.OTHER.GL.POS=FLD.POS<1,3>
    Y.USR.OTHER.PL.POS=FLD.POS<1,4>
    Y.USR.OWN.GLCR.POS=FLD.POS<1,5>
    Y.USR.OWN.PLCR.POS=FLD.POS<1,6>
    Y.USR.OTH.GLCR.POS=FLD.POS<1,7>
    Y.USR.OTH.PLCR.POS=FLD.POS<1,8>
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= FT.PROCESS>
FT.PROCESS:
*** <desc> </desc>
    IF EB.SystemTables.getApplication() EQ 'FUNDS.TRANSFER' THEN

        Y.DR.AC=EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAcctNo)
        Y.CR.AC=EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditAcctNo)
        
        EB.DataAccess.FRead(FN.AC,Y.DR.AC,REC.AC.DR,F.AC,ERR.DR)
        Y.DR.AC.COMP=REC.AC.DR<AC.AccountOpening.Account.CoCode>
   
        EB.DataAccess.FRead(FN.AC,Y.CR.AC,REC.AC.CR,F.AC,ERR.CR)
        Y.CR.AC.COMP=REC.AC.CR<AC.AccountOpening.Account.CoCode>

        IF Y.DR.AC[1,2]='PL' THEN
            !IF Y.DR.AC MATCHES Y.DELIM THEN
            IF Y.DR.AC[8,1] EQ '\' THEN
                EB.DataAccess.FRead(FN.USR,Y.USER.ID,R.USR.REC,F.USR,USR.ERR)
                Y.OTHER.PL.FLG = R.USR.REC<EB.Security.User.UseLocalRef,Y.USR.OTHER.PL.POS>
                
                IF NOT(R.USR.REC) OR Y.OTHER.PL.FLG EQ 'NO' THEN
                    EB.SystemTables.setEtext('Inter Branch PL Transaction Not Allowed')
                    EB.ErrorProcessing.StoreEndError()
                    RETURN

                END
            END ELSE
                EB.DataAccess.FRead(FN.USR,Y.USER.ID,R.USR.REC,F.USR,USR.ERR)
                Y.PL.FLG = R.USR.REC<EB.Security.User.UseLocalRef,Y.USR.OWN.PL.POS>
                
                IF NOT(R.USR.REC) OR Y.PL.FLG EQ 'NO' THEN
                    EB.SystemTables.setEtext('PL Transaction Not Allowed')
                    EB.ErrorProcessing.StoreEndError()
                    RETURN
                END
            END
        END ELSE
            IF NOT(NUM(Y.DR.AC)) AND Y.DR.AC.COMP NE Y.USER.CO.COMP THEN

                EB.DataAccess.FRead(FN.USR,Y.USER.ID,R.USR.REC,F.USR,USR.ERR)
                Y.OTHER.GL.FLG = R.USR.REC<EB.Security.User.UseLocalRef,Y.USR.OTHER.GL.POS>

                IF NOT(R.USR.REC) OR Y.OTHER.GL.FLG EQ 'NO' THEN
                    EB.SystemTables.setEtext('Inter Branch GL Transaction Not Allowed')
                    EB.ErrorProcessing.StoreEndError()
                    RETURN
                END
            END

            IF NOT(NUM(Y.DR.AC)) AND Y.DR.AC.COMP EQ Y.USER.CO.COMP THEN
                EB.DataAccess.FRead(FN.USR,Y.USER.ID,R.USR.REC,F.USR,USR.ERR)
                Y.OWN.GL.FLG = R.USR.REC<EB.Security.User.UseLocalRef,Y.USR.OWN.GL.POS>
                
                IF NOT(R.USR.REC) OR Y.OWN.GL.FLG EQ 'NO' THEN
                    EB.SystemTables.setEtext('GL Transaction Not Allowed')
                    EB.ErrorProcessing.StoreEndError()
                    RETURN
                END
            END
        END

*----------
        !CREDIT FT
*----------

        IF Y.CR.AC[1,2]='PL' THEN
            !IF Y.DR.AC MATCHES Y.DELIM THEN
            IF Y.CR.AC[8,1] EQ '\' THEN
                EB.DataAccess.FRead(FN.USR,Y.USER.ID,R.USR.REC,F.USR,USR.ERR)
                Y.OTHER.PL.CR.FLG = R.USR.REC<EB.Security.User.UseLocalRef,Y.USR.OTH.PLCR.POS>
                
                IF NOT(R.USR.REC) OR Y.OTHER.PL.CR.FLG EQ 'NO' THEN
                    EB.SystemTables.setEtext('Inter Branch PL AC Credit FT Transaction  Not Allowed')
                    EB.ErrorProcessing.StoreEndError()
                    RETURN
                END
            END ELSE
                EB.DataAccess.FRead(FN.USR,Y.USER.ID,R.USR.REC,F.USR,USR.ERR)
                Y.OWN.PL.CR.FLG = R.USR.REC<EB.Security.User.UseLocalRef,Y.USR.OWN.PLCR.POS>
                
                IF NOT(R.USR.REC) OR Y.OWN.PL.CR.FLG EQ 'NO' THEN
                    EB.SystemTables.setEtext('Own Br. PL AC Credit FT Transaction Not Allowed')
                    EB.ErrorProcessing.StoreEndError()
                    RETURN
                END
            END
        END ELSE
            IF NOT(NUM(Y.CR.AC)) AND Y.CR.AC.COMP NE Y.USER.CO.COMP THEN

                EB.DataAccess.FRead(FN.USR,Y.USER.ID,R.USR.REC,F.USR,USR.ERR)
                Y.OTHER.GL.CR.FLG = R.USR.REC<EB.Security.User.UseLocalRef,Y.USR.OTH.GLCR.POS>
                
                IF NOT(R.USR.REC) OR Y.OTHER.GL.CR.FLG EQ 'NO' THEN
                    EB.SystemTables.setEtext('Inter Branch GL AC Credit FT Transaction Not Allowed')
                    EB.ErrorProcessing.StoreEndError()
                    RETURN
                END
            END

            IF NOT(NUM(Y.CR.AC)) AND Y.CR.AC.COMP EQ Y.USER.CO.COMP THEN
                EB.DataAccess.FRead(FN.USR,Y.USER.ID,R.USR.REC,F.USR,USR.ERR)
                Y.OWN.GL.CR.FLG = R.USR.REC<EB.Security.User.UseLocalRef,Y.USR.OWN.GLCR.POS>

                IF NOT(R.USR.REC) OR Y.OWN.GL.CR.FLG EQ 'NO' THEN
                    EB.SystemTables.setEtext('Own Br. GL AC Credit FT Transaction Not Allowed')
                    EB.ErrorProcessing.StoreEndError()
                    RETURN
                END
            END
        END
    END

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= TT.PROCESS>
TT.PROCESS:
*** <desc> </desc>
    IF EB.SystemTables.getApplication() EQ 'TELLER' THEN
        !DEBUG
        IF EB.SystemTables.getRNew(TT.Contract.Teller.TeDrCrMarker) EQ 'DEBIT' THEN
            Y.DR.AC=EB.SystemTables.getRNew(TT.Contract.Teller.TeAccountOne)
            Y.CR.AC=EB.SystemTables.getRNew(TT.Contract.Teller.TeAccountTwo)
        END
        ELSE
            Y.DR.AC=EB.SystemTables.getRNew(TT.Contract.Teller.TeAccountTwo)
            Y.CR.AC=EB.SystemTables.getRNew(TT.Contract.Teller.TeAccountOne)
        END

        EB.DataAccess.FRead(FN.AC,Y.DR.AC,REC.AC.DR,F.AC,ERR.DR)
        EB.DataAccess.FRead(FN.AC,Y.CR.AC,REC.AC.CR,F.AC,ERR.CR)
        Y.DR.AC.COMP=REC.AC.DR<AC.AccountOpening.Account.CoCode>
        Y.CR.AC.COMP=REC.AC.CR<AC.AccountOpening.Account.CoCode>
        Y.DR.CATEG=REC.AC.DR<AC.AccountOpening.Account.Category>
        Y.CR.CATEG=REC.AC.CR<AC.AccountOpening.Account.Category>


        IF Y.DR.AC[1,2]='PL' THEN
            !IF Y.DR.AC MATCHES Y.DELIM THEN
            IF Y.DR.AC[8,1] EQ '\' THEN
                EB.DataAccess.FRead(FN.USR,Y.USER.ID,R.USR.REC,F.USR,USR.ERR)
                Y.OTHER.PL.FLG = R.USR.REC<EB.Security.User.UseLocalRef,Y.USR.OTHER.PL.POS>

                IF NOT(R.USR.REC) OR Y.OTHER.PL.FLG EQ 'NO' THEN
                    EB.SystemTables.setEtext('Inter Branch PL Transaction Not Allowed')
                    EB.ErrorProcessing.StoreEndError()
                    RETURN
                END
            END
            ELSE
                EB.DataAccess.FRead(FN.USR,Y.USER.ID,R.USR.REC,F.USR,USR.ERR)
                Y.PL.FLG = R.USR.REC<EB.Security.User.UseLocalRef,Y.USR.OWN.PL.POS>

                IF NOT(R.USR.REC) OR Y.PL.FLG EQ 'NO' THEN
                    EB.SystemTables.setEtext('PL Transaction Not Allowed')
                    EB.ErrorProcessing.StoreEndError()
                    RETURN
                END
            END
        END

        ELSE IF NOT(NUM(Y.DR.AC)) THEN
            IF NOT(NUM(Y.CR.AC)) THEN
                Y.CR.AC.TEST ='A'
            END

            Y.DR.CATEGORY.EXP.LIST='10001':@FM:'10011':@FM:'14025'

            FIND Y.DR.CATEG IN Y.DR.CATEGORY.EXP.LIST SETTING Y.POS1,Y.POS2 THEN
                Y.DR.EXP='Y'

                IF (Y.DR.EXP EQ 'Y') AND Y.CR.AC.TEST NE 'A' AND Y.DR.AC.COMP EQ Y.USER.CO.COMP THEN
                    RETURN
                END
            END ELSE
                IF Y.DR.EXP NE 'Y' AND Y.DR.AC.COMP EQ Y.USER.CO.COMP THEN

                    EB.DataAccess.FRead(FN.USR,Y.USER.ID,R.USR.REC,F.USR,USR.ERR)
                    Y.OWN.GL.FLG = R.USR.REC<EB.Security.User.UseLocalRef,Y.USR.OWN.GL.POS>

                    IF NOT(R.USR.REC) OR Y.OWN.GL.FLG EQ 'NO' THEN
                        EB.SystemTables.setEtext('GL Transaction Not Allowed')
                        EB.ErrorProcessing.StoreEndError()
                        RETURN
                    END
                END

                IF Y.DR.AC.COMP NE Y.USER.CO.COMP THEN

                    EB.DataAccess.FRead(FN.USR,Y.USER.ID,R.USR.REC,F.USR,USR.ERR)
                    Y.OTHER.GL.FLG = R.USR.REC<EB.Security.User.UseLocalRef,Y.USR.OTHER.GL.POS>

                    IF NOT(R.USR.REC) OR Y.OTHER.GL.FLG EQ 'NO' THEN

                        EB.SystemTables.setEtext('Inter Branch GL Transaction Not Allowed')
                        EB.ErrorProcessing.StoreEndError()
                        RETURN
                    END
                END
            END
        END


*----------
        !CREDIT TT
*----------

        IF Y.CR.AC[1,2]='PL' THEN
            !IF Y.DR.AC MATCHES Y.DELIM THEN
            IF Y.CR.AC[8,1] EQ '\' THEN
                EB.DataAccess.FRead(FN.USR,Y.USER.ID,R.USR.REC,F.USR,USR.ERR)
                Y.OTHER.PL.CR.FLG = R.USR.REC<EB.Security.User.UseLocalRef,Y.USR.OTH.PLCR.POS>

                IF NOT(R.USR.REC) OR Y.OTHER.PL.CR.FLG EQ 'NO' THEN
                    EB.SystemTables.setEtext('Inter Branch PL AC Credit TT Transaction  Not Allowed')
                    EB.ErrorProcessing.StoreEndError()
                    RETURN
                END
            END
            ELSE
                EB.DataAccess.FRead(FN.USR,Y.USER.ID,R.USR.REC,F.USR,USR.ERR)
                Y.OWN.PL.CR.FLG = R.USR.REC<EB.Security.User.UseLocalRef,Y.USR.OWN.PLCR.POS>

                IF NOT(R.USR.REC) OR Y.OWN.PL.CR.FLG EQ 'NO' THEN
                    EB.SystemTables.setEtext('Own Br. PL AC Credit TT Transaction Not Allowed')
                    EB.ErrorProcessing.StoreEndError()
                    RETURN
                END
            END
        END

        ELSE IF NOT(NUM(Y.CR.AC)) THEN

            Y.CR.CATEGORY.EXP.LIST='10001':@FM:'10011':@FM:'14025'

            FIND Y.CR.CATEG IN Y.CR.CATEGORY.EXP.LIST SETTING Y.POS1,Y.POS2 THEN
                Y.CR.EXP='Y'

                IF (Y.CR.EXP EQ 'Y')  AND Y.CR.AC.COMP EQ Y.USER.CO.COMP THEN
                    RETURN
                END
            END ELSE

                IF Y.CR.EXP NE 'Y' AND Y.CR.AC.COMP EQ Y.USER.CO.COMP THEN

                    EB.DataAccess.FRead(FN.USR,Y.USER.ID,R.USR.REC,F.USR,USR.ERR)
                    Y.OWN.GL.CR.FLG = R.USR.REC<EB.Security.User.UseLocalRef,Y.USR.OWN.GLCR.POS>

                    IF NOT(R.USR.REC) OR Y.OWN.GL.CR.FLG EQ 'NO' THEN
                        EB.SystemTables.setEtext('Own Br. GL AC Credit TT Transaction Not Allowed')
                        EB.ErrorProcessing.StoreEndError()
                        RETURN
                    END

                END

                IF Y.CR.AC.COMP NE Y.USER.CO.COMP THEN

                    EB.DataAccess.FRead(FN.USR,Y.USER.ID,R.USR.REC,F.USR,USR.ERR)
                    Y.OTHER.GL.CR.FLG = R.USR.REC<EB.Security.User.UseLocalRef,Y.USR.OTH.GLCR.POS>

                    IF NOT(R.USR.REC) OR Y.OTHER.GL.CR.FLG EQ 'NO' THEN
                        EB.SystemTables.setEtext('Inter Branch GL AC Credit TT Transaction Not Allowed')
                        EB.ErrorProcessing.StoreEndError()
                        RETURN
                    END
                END
            END
        END
    END

RETURN
*** </region>

END




