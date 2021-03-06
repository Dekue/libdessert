/*
 * Note: this file originally auto-generated by mib2c using
 *       version : 14170 $ of $
 *
 * $Id:$
 */
#ifndef DESSERTAPPSTATSTABLE_H
#define DESSERTAPPSTATSTABLE_H

#ifdef __cplusplus
extern          "C" {
#endif


/** @addtogroup misc misc: Miscellaneous routines
 *
 * @{
 */
#include <net-snmp/library/asn1.h>

    /*
     * other required module components 
     */
    /* *INDENT-OFF*  */
config_add_mib(DESSERT-MIB)
config_require(DESSERT-MIB/dessertAppStatsTable/dessertAppStatsTable_interface)
config_require(DESSERT-MIB/dessertAppStatsTable/dessertAppStatsTable_data_access)
config_require(DESSERT-MIB/dessertAppStatsTable/dessertAppStatsTable_data_get)
config_require(DESSERT-MIB/dessertAppStatsTable/dessertAppStatsTable_data_set)
    /* *INDENT-ON*  */

    /*
     * OID and column number definitions for dessertAppStatsTable 
     */
#include "dessertAppStatsTable_oids.h"

    /*
     * enum definions 
     */
#include "dessertAppStatsTable_enums.h"

    /*
     *********************************************************************
     * function declarations
     */
    void            init_dessertAppStatsTable(void);
    void            shutdown_dessertAppStatsTable(void);

    /*
     *********************************************************************
     * Table declarations
     */
/**********************************************************************
 **********************************************************************
 ***
 *** Table dessertAppStatsTable
 ***
 **********************************************************************
 **********************************************************************/
    /*
     * DESSERT-MIB::dessertAppStatsTable is subid 8 of dessertObjects.
     * Its status is Current.
     * OID: .1.3.6.1.4.1.18898.0.19.10.1.1.8, length: 12
     */
    /*
     *********************************************************************
     * When you register your mib, you get to provide a generic
     * pointer that will be passed back to you for most of the
     * functions calls.
     *
     * TODO:100:r: Review all context structures
     */
    /*
     * TODO:101:o: |-> Review dessertAppStatsTable registration context.
     */
    typedef netsnmp_data_list dessertAppStatsTable_registration;

/**********************************************************************/
    /*
     * TODO:110:r: |-> Review dessertAppStatsTable data context structure.
     * This structure is used to represent the data for dessertAppStatsTable.
     */
    /*
     * This structure contains storage for all the columns defined in the
     * dessertAppStatsTable.
     */
    typedef struct dessertAppStatsTable_data_s {

        /*
         * appStatsName(2)/DisplayString/ASN_OCTET_STR/char(char)//L/A/w/e/R/d/H
         */
        char            appStatsName[255];
        size_t          appStatsName_len;       /* # of char elements, not bytes */

        /*
         * appStatsDesc(3)/DisplayString/ASN_OCTET_STR/char(char)//L/A/w/e/R/d/H
         */
        char            appStatsDesc[255];
        size_t          appStatsDesc_len;       /* # of char elements, not bytes */

        /*
         * appStatsNodeOrLink(4)/INTEGER/ASN_INTEGER/long(u_long)//l/A/w/E/r/d/h
         */
        u_long          appStatsNodeOrLink;

        /*
         * appStatsValueType(5)/INTEGER/ASN_INTEGER/long(u_long)//l/A/w/E/r/d/h
         */
        u_long          appStatsValueType;

        /*
         * appStatsMacAddress1(6)/MacAddress/ASN_OCTET_STR/char(char)//L/A/w/e/R/d/H
         */
        char            appStatsMacAddress1[6];
        size_t          appStatsMacAddress1_len;        /* # of char elements, not bytes */

        /*
         * appStatsMacAddress2(7)/MacAddress/ASN_OCTET_STR/char(char)//L/A/w/e/R/d/H
         */
        char            appStatsMacAddress2[6];
        size_t          appStatsMacAddress2_len;        /* # of char elements, not bytes */

        /*
         * appStatsTruthValue(8)/TruthValue/ASN_INTEGER/long(u_long)//l/A/w/E/r/d/h
         */
        u_long          appStatsTruthValue;

        /*
         * appStatsInteger32(9)/INTEGER32/ASN_INTEGER/long(long)//l/A/w/e/r/d/h
         */
        long            appStatsInteger32;

        /*
         * appStatsUnsigned32(10)/UNSIGNED32/ASN_UNSIGNED/u_long(u_long)//l/A/w/e/r/d/h
         */
        u_long          appStatsUnsigned32;

        /*
         * appStatsCounter64(11)/COUNTER64/ASN_COUNTER64/U64(U64)//l/A/w/e/r/d/h
         */
        U64             appStatsCounter64;

        /*
         * appStatsOctetString(12)/OCTETSTR/ASN_OCTET_STR/char(char)//L/A/w/e/R/d/h
         */
        char            appStatsOctetString[1024];
        size_t          appStatsOctetString_len;        /* # of char elements, not bytes */

    } dessertAppStatsTable_data;


    /*
     * TODO:120:r: |-> Review dessertAppStatsTable mib index.
     * This structure is used to represent the index for dessertAppStatsTable.
     */
    typedef struct dessertAppStatsTable_mib_index_s {

        /*
         * appStatsIndex(1)///()//L/a/w/e/r/d/h
         */
        long appStatsIndex;


    } dessertAppStatsTable_mib_index;

    /*
     * TODO:121:r: |   |-> Review dessertAppStatsTable max index length.
     * If you KNOW that your indexes will never exceed a certain
     * length, update this macro to that length.
     */
#define MAX_dessertAppStatsTable_IDX_LEN     1


    /*
     *********************************************************************
     * TODO:130:o: |-> Review dessertAppStatsTable Row request (rowreq) context.
     * When your functions are called, you will be passed a
     * dessertAppStatsTable_rowreq_ctx pointer.
     */
    typedef struct dessertAppStatsTable_rowreq_ctx_s {

    /** this must be first for container compare to work */
        netsnmp_index   oid_idx;
        oid             oid_tmp[MAX_dessertAppStatsTable_IDX_LEN];

        dessertAppStatsTable_mib_index tbl_idx;

        dessertAppStatsTable_data data;
        unsigned int    column_exists_flags;    /* flags for existence */

        /*
         * flags per row. Currently, the first (lower) 8 bits are reserved
         * for the user. See mfd.h for other flags.
         */
        uint           rowreq_flags;

        /*
         * TODO:131:o: |   |-> Add useful data to dessertAppStatsTable rowreq context.
         */

        /*
         * storage for future expansion
         */
        netsnmp_data_list *dessertAppStatsTable_data_list;

    } dessertAppStatsTable_rowreq_ctx;

    typedef struct dessertAppStatsTable_ref_rowreq_ctx_s {
        dessertAppStatsTable_rowreq_ctx *rowreq_ctx;
    } dessertAppStatsTable_ref_rowreq_ctx;

    /*
     *********************************************************************
     * function prototypes
     */
    int            
        dessertAppStatsTable_pre_request(dessertAppStatsTable_registration
                                         * user_context);
    int            
        dessertAppStatsTable_post_request(dessertAppStatsTable_registration
                                          * user_context, int rc);


    dessertAppStatsTable_rowreq_ctx
        *dessertAppStatsTable_row_find_by_mib_index
        (dessertAppStatsTable_mib_index * mib_idx);

    extern oid      dessertAppStatsTable_oid[];
    extern int      dessertAppStatsTable_oid_size;


#include "dessertAppStatsTable_interface.h"
#include "dessertAppStatsTable_data_access.h"
#include "dessertAppStatsTable_data_get.h"
#include "dessertAppStatsTable_data_set.h"

    /*
     * DUMMY markers, ignore
     *
     * TODO:099:x: *************************************************************
     * TODO:199:x: *************************************************************
     * TODO:299:x: *************************************************************
     * TODO:399:x: *************************************************************
     * TODO:499:x: *************************************************************
     */

#ifdef __cplusplus
}
#endif
#endif                          /* DESSERTAPPSTATSTABLE_H */
/** @} */
