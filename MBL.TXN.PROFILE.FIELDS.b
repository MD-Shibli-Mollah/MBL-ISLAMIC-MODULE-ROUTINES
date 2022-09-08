* @ValidationCode : MjotNDMxNzY5MzQ1OkNwMTI1MjoxNTkyODAxOTk5MjEwOkRFTEw6LTE6LTE6MDowOnRydWU6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 22 Jun 2020 10:59:59
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : true
* @ValidationInfo : Compiler Version  : DEV_201710.0
*-----------------------------------------------------------------------------
* <Rating>-7</Rating>
*-----------------------------------------------------------------------------
SUBROUTINE MBL.TXN.PROFILE.FIELDS
*-----------------------------------------------------------------------------
*<doc>
* Template for field definitions routine <<PREFIX>>.MBL.TXN.PROFILE.FIELDS
*
* @author tcoleman@temenos.com
* @stereotype fields template
* @uses Table
* @public Table Creation
* @package infra.eb
* </doc>
*-----------------------------------------------------------------------------
* Developed By- Akhter Hossain
* Modification History :
*
* 19/10/07 - EN_10003543
*            New Template changes
*
* 14/11/07 - BG_100015736
*            Exclude routines that are not released
*-----------------------------------------------------------------------------
*** <region name= Header>
*** <desc>Inserts and control logic</desc>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DataTypes
    $INSERT I_F.ACCOUNT
    $USING EB.SystemTables
    $USING AC.AccountOpening
    
*** </region>
*-----------------------------------------------------------------------------
    CALL Table.defineId("REC.ID", T24_Account) ;* Define Table id
    EB.SystemTables.setIdCheckfile('ACCOUNT')
    EB.SystemTables.setIdEnri(AC.AccountOpening.Account.ShortTitle)
*-----------------------------------------------------------------------------
    CALL Table.addFieldDefinition("ACCOUNT.TITLE", "35", "A", "") ;* Add a new field
    CALL Table.addFieldDefinition("MONTHLY.EXP.INC", "20", "AMT", "") ;* Add a new field
    CALL Table.addFieldDefinition("HDR.DEP.CSH", "3", "A", "") ;* Add a new field
    CALL Table.addFieldDefinition("CASH.DEP.NO", "4", "", "") ;* Add a new field
    CALL Table.addFieldDefinition("CASH.DEP.AMT", "20", "AMT", "") ;* Add a new field
    CALL Table.addFieldDefinition("CASH.DEP.MAX", "20", "AMT", "") ;* Add a new field
    CALL Table.addFieldDefinition("HDR.DEP.TRF", "3", "A", "") ;* Add a new field
    CALL Table.addFieldDefinition("TRF.DEP.NO", "4", "", "") ;* Add a new field
    CALL Table.addFieldDefinition("TRF.DEP.AMT", "20", "AMT", "") ;* Add a new field
    CALL Table.addFieldDefinition("TRF.DEP.MAX", "20", "AMT", "") ;* Add a new field
    CALL Table.addFieldDefinition("HDR.DEP.RMT", "3", "A", "") ;* Add a new field
    CALL Table.addFieldDefinition("RMT.DEP.NO", "4", "", "") ;* Add a new field
    CALL Table.addFieldDefinition("RMT.DEP.AMT", "20", "AMT", "") ;* Add a new field
    CALL Table.addFieldDefinition("RMT.DEP.MAX", "20", "AMT", "") ;* Add a new field
    CALL Table.addFieldDefinition("HDR.DEP.EXP", "3", "A", "") ;* Add a new field
    CALL Table.addFieldDefinition("EXP.DEP.NO", "4", "", "") ;* Add a new field
    CALL Table.addFieldDefinition("EXP.DEP.AMT", "20", "AMT", "") ;* Add a new field
    CALL Table.addFieldDefinition("EXP.DEP.MAX", "20", "AMT", "") ;* Add a new field
    CALL Table.addFieldDefinition("HDR.DEP.BOA", "3", "A", "") ;* Add a new field
    CALL Table.addFieldDefinition("BOA.DEP.NO", "4", "", "") ;* Add a new field
    CALL Table.addFieldDefinition("BOA.DEP.AMT", "20", "AMT", "") ;* Add a new field
    CALL Table.addFieldDefinition("BOA.DEP.MAX", "20", "AMT", "") ;* Add a new field
    CALL Table.addFieldDefinition("HDR.DEP.OTH", "3", "A", "") ;* Add a new field
    CALL Table.addFieldDefinition("OTH.DEP.NO", "4", "", "") ;* Add a new field
    CALL Table.addFieldDefinition("OTH.DEP.AMT", "20", "AMT", "") ;* Add a new field
    CALL Table.addFieldDefinition("OTH.DEP.MAX", "20", "AMT", "") ;* Add a new field
    CALL Table.addFieldDefinition("HDR.DEP.RES", "3", "A", "") ;* Add a new field
    CALL Table.addFieldDefinition("RES.DEP.NO", "4", "", "") ;* Add a new field
    CALL Table.addFieldDefinition("RES.DEP.AMT", "20", "AMT", "") ;* Add a new field
    CALL Table.addFieldDefinition("RES.DEP.MAX", "20", "AMT", "") ;* Add a new field
    CALL Table.addFieldDefinition("HDR.DEP.TOT", "3", "A", "") ;* Add a new field
    CALL Table.addFieldDefinition("TOT.DEP.NO", "4", "", "") ;* Add a new field
    CALL Table.addFieldDefinition("TOT.DEP.AMT", "20", "AMT", "") ;* Add a new field
    CALL Table.addFieldDefinition("TOT.DEP.MAX", "20", "AMT", "") ;* Add a new field
    CALL Table.addFieldDefinition("HDR.WDL.CSH", "3", "A", "") ;* Add a new field
    CALL Table.addFieldDefinition("CASH.WDL.NO", "4", "", "") ;* Add a new field
    CALL Table.addFieldDefinition("CASH.WDL.AMT", "20", "AMT", "") ;* Add a new field
    CALL Table.addFieldDefinition("CASH.WDL.MAX", "20", "AMT", "") ;* Add a new field
    CALL Table.addFieldDefinition("HDR.WDL.TRF", "3", "A", "") ;* Add a new field
    CALL Table.addFieldDefinition("TRF.WDL.NO", "4", "", "") ;* Add a new field
    CALL Table.addFieldDefinition("TRF.WDL.AMT", "20", "AMT", "") ;* Add a new field
    CALL Table.addFieldDefinition("TRF.WDL.MAX", "20", "AMT", "") ;* Add a new field
    CALL Table.addFieldDefinition("HDR.WDL.RMT", "3", "A", "") ;* Add a new field
    CALL Table.addFieldDefinition("RMT.WDL.NO", "4", "", "") ;* Add a new field
    CALL Table.addFieldDefinition("RMT.WDL.AMT", "20", "AMT", "") ;* Add a new field
    CALL Table.addFieldDefinition("RMT.WDL.MAX", "20", "AMT", "") ;* Add a new field
    CALL Table.addFieldDefinition("HDR.WDL.IMP", "3", "A", "") ;* Add a new field
    CALL Table.addFieldDefinition("IMP.WDL.NO", "4", "", "") ;* Add a new field
    CALL Table.addFieldDefinition("IMP.WDL.AMT", "20", "AMT", "") ;* Add a new field
    CALL Table.addFieldDefinition("IMP.WDL.MAX", "20", "AMT", "") ;* Add a new field
    CALL Table.addFieldDefinition("HDR.WDL.BOA", "3", "A", "") ;* Add a new field
    CALL Table.addFieldDefinition("BOA.WDL.NO", "4", "", "") ;* Add a new field
    CALL Table.addFieldDefinition("BOA.WDL.AMT", "20", "AMT", "") ;* Add a new field
    CALL Table.addFieldDefinition("BOA.WDL.MAX", "20", "AMT", "") ;* Add a new field
    CALL Table.addFieldDefinition("HDR.WDL.OTH", "3", "A", "") ;* Add a new field
    CALL Table.addFieldDefinition("OTH.WDL.NO", "4", "", "") ;* Add a new field
    CALL Table.addFieldDefinition("OTH.WDL.AMT", "20", "AMT", "") ;* Add a new field
    CALL Table.addFieldDefinition("OTH.WDL.MAX", "20", "AMT", "") ;* Add a new field
    CALL Table.addFieldDefinition("HDR.WDL.RES", "3", "A", "") ;* Add a new field
    CALL Table.addFieldDefinition("RES.WDL.NO", "4", "", "") ;* Add a new field
    CALL Table.addFieldDefinition("RES.WDL.AMT", "20", "AMT", "") ;* Add a new field
    CALL Table.addFieldDefinition("RES.WDL.MAX", "20", "AMT", "") ;* Add a new field
    CALL Table.addFieldDefinition("HDR.WDL.TOT", "3", "A", "") ;* Add a new field
    CALL Table.addFieldDefinition("TOT.WDL.NO", "4", "", "") ;* Add a new field
    CALL Table.addFieldDefinition("TOT.WDL.AMT", "20", "AMT", "") ;* Add a new field
    CALL Table.addFieldDefinition("TOT.WDL.MAX", "20", "AMT", "") ;* Add a new field
    CALL Table.addFieldDefinition("HDR.NOB.OCCP", "3", "A", "") ;* Add a new field
    CALL Table.addFieldDefinition("NOB.OCCUPATION", "65","":FM:"CORP: 01. Jewelry /Gold Related/Precious Metal Business (05)_CORP: 02. Money Exch./Courier Service/Mobile/Agent Banking (05)_CORP: 03. Real Estate Developer/Agent (05)_CORP: 04. Construction Project Promoter/Contractor (05)_CORP: 05. Off-Shore/Non-Resident Corporation (05)_CORP: 06. Restaurant/Bar/Night Club/Residential Hotel/Parlor (05)_CORP: 07. Import/Export & Import/Export Agent (05)_CORP: 08. Garment Bus./Accessories/Packaging/Buying House (05)_CORP: 09. Share Dealer,Broker,Portf. Manager,Merchant Banker (05)_CORP: 10. NGO/NPO (05)_CORP: 11. Manpower Export Business (05)_CORP: 12. Film Producer/Distributor Company (05)_CORP: 13. Arms Business (05)_CORP: 14. Mobile Phone Operator/Internet/Cable TV Operator (05)_CORP: 15. Land/House Buy-Sales Broker Institutional (05)_CORP: 16. Bank/Leasing/Finance Company (05)_CORP: 17. Transport Operator (05)_CORP: 18. Insurance/Brokerage Agency (05)_CORP: 19. Religious Instituition/Educational Instituition (05)_CORP: 20. Trust (05)_CORP: 21. Business - Petrol Pump/CNG Station (05)_CORP: 22. Tobacco & Cigerette Business (05)_CORP: 23. Software Business (05)_CORP: 24. Ship Breaking Business (05)_CORP: 25. Business - Clearing & Forwarding Agent (04)_CORP: 26. Business - Dealer/Distributor Agent (04)_CORP: 27. Business - Indenting (04)_CORP: 28. Business - Outsourcing (04)_CORP: 29. Event Management (04)_CORP: 30. Chartered Accountant (04)_CORP: 31. Corporate Account Holder (04)_CORP: 32. Law Firm/Engineering Firm/Consultancy Firm (04)_CORP: 33. Energy & Electricity Production Company (04)_CORP: 34. Print / Electronic Media (04)_CORP: 35. Travel Agent/Tourism Company (04)_CORP: 36. Auto Dealer - Reconditioned Car (04)_CORP: 37. Freight/Shipping/Cargo Agent/CNF Agent (04)_CORP: 38. Auto Primary - New Car Business (04)_CORP: 39. House Construction Material Business (04)_CORP: 40. Business - Leather & Leather Made Goods (04)_CORP: 41. Tele-Communication Company (04)_CORP: 42. Chain Store/Shopping Malll (04)_CORP: 43. Textile/Spinning (03)_CORP: 44. Entertainment Institution/Amusement Park (03)_CORP: 45. Motor Parts / Workshop Business (03)_CORP: 46. Business - Agent (03)_CORP: 47. Business- Medicine/Drug Manufac. & Marketing Co (03)_CORP: 48. Refrigeration Business - Cold Storage (03)_CORP: 49. Business - Frozen Food (03)_CORP: 50. Business - Hardware (03)_CORP: 51. Business - Advertisement (03)_CORP: 52. Service Provider (03)_CORP: 53. Computer/Mobile Phone Dealer (02)_CORP: 54. Poultry/Dairy/Fishing Firm (02)_CORP: 55. Agro Business/Rice Mill Business/Beverage (02)_CORP: 56. Manufacturer - Excluding Arms (02)_CORP: 57. Shops - Retail Business (02)_CORP: 58. Others (01)_CORP: 59. Others (02)_CORP: 60. Others (03)_CORP: 61. Others (04)_CORP: 62. Others (05)_INDV: 01. Trade of Jewelry /Gold Related/Precious Metal (05)_INDV: 02. Money Changer/Courier Service/Mobile Banking Agent (05)_INDV: 03. Real Estate Developer/Agent (05)_INDV: 04. Contractor/Promoter of Construction Project (05)_INDV: 05. Art/Antique Dealer (05)_INDV: 06. Restaurant/Bar/Night Club/Residential Hotel/Parlor (05)_INDV: 07. Import/Export (05)_INDV: 08. Manpower Export Business (05)_INDV: 09. Arms Dealer (05)_INDV: 10. Garment Business/Garment Accessories/Buying House (05)_INDV: 11. Pilot/Flight Attendant (05)_INDV: 12. Trusty (05)_INDV: 13. Investor in Share/Stock Business (05)_INDV: 14. Software/Information & Technology Business (05)_INDV: 15. Expatriate Working in Bangladesh (05)_INDV: 16. Travel Agent (04)_INDV: 17. Business with Annual Inv. of more than Tk. 1 Crore (04)_INDV: 18. Freight/Shipping Cargo Agent (04)_INDV: 19. Auto Dealer - New/Reconditioned Car (04)_INDV: 20. Business - Leather & Leather Goods (04)_INDV: 21. Home Construction Material Business (04)_INDV: 22. Professional-Journalist,Lawyer,Doctor, Engineer,CA (04)_INDV: 23. Director - Private/Public Limited Company (04)_INDV: 24. High Officials of Multi National Company (04)_INDV: 25. Housewife (04)_INDV: 26. Service in Information Technology Sector (04)_INDV: 27. Sportsman/Media Celebrity/Producer/Director (04)_INDV: 28. Freelance Software Developer (04)_INDV: 29. Business - Agent (03)_INDV: 30. Government Service (03)_INDV: 31. Landlord (03)_INDV: 32. Cotton Business/Trader of Garments Leftovers (03)_INDV: 33. Transport Operator (03)_INDV: 34. Tobacco & Cigarrete Business (03)_INDV: 35. Amusement Instituition/Park (03)_INDV: 36. Motor Parts/Workshop Business (03)_INDV: 37. Private Service Managerial (03)_INDV: 38. Teacher - Govt./Pvt./Aut. Educational Instituition (02)_INDV: 39. Service - Private Sector (02)_INDV: 40. Small Trader - Annual Turnover not over Tk. 50 Lac (02)_INDV: 41. Self Employed Professional (02)_INDV: 42. Computer/Mobile Phone Dealer (02)_INDV: 43. Manufacturer - Other than Arms (02)_INDV: 44. Student (02)_INDV: 45. Retired from Service (01)_INDV: 46. Farmer/Worker/Fisherman (01)_INDV: 47. Others (01)_INDV: 48. Others (02)_INDV: 49. Others (03)_INDV: 50. Others (04)_INDV: 51. Others (05)", "") ;* Add a new field
    CALL Table.addFieldDefinition("HDR.NW.MI", "3", "A", "") ;* Add a new field
    CALL Table.addFieldDefinition("NET.WORTH.MONT.INC", "65","":FM:"CORP: 0 - 1 Crore = Low (0)_CORP: 1 - 3 Crore = Medium (1)_CORP: Above 3 Crore = High (3)_INDV: 0 - 1 Lac Low (0)_INDV: Above 1 Lac - 3 Lac Medium (1)_INDV: Above 3 Lac High (3)", "") ;* Add a new field
    CALL Table.addFieldDefinition("HDR.AC.OPN.WAY", "3", "A", "") ;* Add a new field
    CALL Table.addFieldDefinition("ACC.OPENED.WAY", "65","":FM:"Relationship Manager/Branch (0)_Direct Sales Agent (3)_Internet/Non Face to Face (3)_Walk-In (3)", "") ;* Add a new field
    CALL Table.addFieldDefinition("HDR.TOT.TXN.AMT", "3", "A", "") ;* Add a new field
    CALL Table.addFieldDefinition("TOT.TXN.AMT", "65","":FM:"CORP: CD 0 - 10 Lac = Low (0)_CORP: CD 10 - 50 Lac = Medium (1)_CORP: CD Above 50 Lac = High (3)_CORP: SB 0 - 5 Lac = Low (0)_CORP: SB 5 - 20 Lac = Medium (1)_CORP: SB Above 20 Lac = High (3)_INDV: CD 0 - 10 Lac = Low (0)_INDV: CD 10 - 20 Lac = Medium (1)_INDV: CD Above 20 Lac = High (3)_INDV: SB 0 - 5 Lac = Low (0)_INDV: SB 5 - 10 Lac = Medium (1)_INDV: SB Above 10 Lac = High (3)", "") ;* Add a new field
    CALL Table.addFieldDefinition("HDR.TOT.TXN.NO", "3", "A", "") ;* Add a new field
    CALL Table.addFieldDefinition("TOT.TXN.NO", "65","":FM:"CORP: CD 0 - 100 = Low (0)_CORP: CD 101 - 250 = Medium (1)_CORP: CD Above 250 = High (3)_CORP: SB 0 - 20 = Low (0)_CORP: SB 21 - 50 = Medium (1)_CORP: SB Above 50 = High (3)_INDV: CD 0 - 15 = Low (0)_INDV: CD 16 - 25 = Medium (1)_INDV: CD Above 25 = High (3)_INDV: SB 0 - 10 = Low (0)_INDV: SB 11 - 20 = Medium (1)_INDV: SB Above 20 = High (3)", "") ;* Add a new field
    CALL Table.addFieldDefinition("HDR.CSH.TXN.AMT", "3", "A", "") ;* Add a new field
    CALL Table.addFieldDefinition("CASH.TXN.AMT", "65","":FM:"CORP: CD 0 - 10 Lac = Low (0)_CORP: CD 10 - 25 Lac = Medium (1)_CORP: CD Above 25 Lac = High (3)_CORP: SB 0 - 2 Lac = Low (0)_CORP: SB 2 - 7 Lac = Medium (1)_CORP: SB Above 7 Lac = High (3)_INDV: CD 0 - 5 Lac = Low (0)_INDV: CD 5 - 10 Lac = Medium (1)_INDV: CD Above 10 Lac = High (3)_INDV: SB 0 - 2 Lac = Low (0)_INDV: SB 2 - 5 Lac = Medium (1)_INDV: SB Above 5 Lac = High (3)", "") ;* Add a new field
    CALL Table.addFieldDefinition("HDR.CSH.TXN.NO", "3", "A", "") ;* Add a new field
    CALL Table.addFieldDefinition("CASH.TXN.NO", "65","":FM:"CORP: CD 0 - 15 = Low (0)_CORP: CD 16 - 30 = Medium (1)_CORP: CD Above 30 = High (3)_CORP: SB 0 - 5 = Low (0)_CORP: SB 6 - 10 = Medium (1)_CORP: SB Above 10 = High (3)_INDV: CD 0 - 10 = Low (0)_INDV: CD 11 - 20 = Medium (1)_INDV: CD Above 20 = High (3)_INDV: SB 0 - 5 = Low (0)_INDV: SB 6 - 10 = Medium (1)_INDV: SB Above 10 = High (3)", "") ;* Add a new field
*----  NEW FIELD ADDED
    CALL Table.addFieldDefinition("HDR.SUM.RISK", "3", "A", "") ;* Add a new field
    CALL Table.addFieldDefinition("TOTAL.RISK.SUM", "10", "A", "") ;* Add a new field
*--------------
    CALL Table.addFieldDefinition("HDR.TOT.RISK", "3", "A", "") ;* Add a new field
    CALL Table.addFieldDefinition("TOTAL.RISK.RATING", "10", "A", "") ;* Add a new field
    CALL Table.addFieldDefinition("CORP.INDV.MARKER", "12", "":FM:"CORPORATE_INDIVIDUAL", "") ;* Add a new field
    CALL Table.addFieldDefinition("MONTH.EST.TOVR", "20", "AMT", "") ;* Add a new field
    CALL Table.addReservedField("RESERVED.5")
    CALL Table.addReservedField("RESERVED.4")
    CALL Table.addReservedField("RESERVED.3")
    CALL Table.addReservedField("RESERVED.2")
    CALL Table.addReservedField("RESERVED.1")
    
    CALL Table.addLocalReferenceField('XX.LOCAL.REF')
    CALL Table.addOverrideField
    
*-----------------------------------------------------------------------------
    CALL Table.setAuditPosition ;* Poputale audit information
*-----------------------------------------------------------------------------
RETURN
*-----------------------------------------------------------------------------
END
