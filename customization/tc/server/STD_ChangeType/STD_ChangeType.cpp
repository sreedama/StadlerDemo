
#include <iostream>
#include <fstream>
#include <string>

#include <vector>

#include <tc/tc_startup.h>
#include <tccore/aom.h>
#include <tccore/aom_prop.h>
#include <sa/sa.h>
#include <tcinit/tcinit.h>
#include <tccore/item.h>
#include <bom/bom.h>
#include <tccore/grm.h>
#include <ae/dataset.h>
#include <tccore/tctype.h>
#include <pom/enq/enq.h>
#include <regex>

#undef STD_FREE
#define STD_FREE( a )   \
do                          \
{                           \
    if ( (a) != NULL )      \
    {                       \
        MEM_free( (a) );    \
        (a) = NULL;         \
    }                       \
}                           \
while ( (a) != NULL )

#define RETURN_ERROR(x) retcode = (x); if(retcode != ITK_ok) return retcode

#define LOG_AND_PROCEED(t, f) \
    if(retcode == ITK_ok) { \
        retcode = f;\
        if(retcode != ITK_ok) { \
            std::cerr << std::endl << t << ": "; \
            logStream << std::endl << t << ": "; \
            std::cerr << "ERROR: failed (" << retcode << "): " << std::endl; \
            logStream << "ERROR: failed (" << retcode << "): " << std::endl; \
            retcode = ITK_ok; \
        } \
    }

#define logStream \
    if (!logFileSet) {} \
    else _logfile 

static bool logFileSet = false;
static std::ofstream _logfile;

static void display_usage(
    char* s_application     /* <I> */
);

static int startup_ITK(
    char* sp_user,
    char* szPasswdFile,
    char* sp_group);

static int change_types(const char* pInputFile);
static int change_item_type(tag_t tItem, const std::vector<std::string> &types);
static int unload_instances(int n, tag_t * tags);

int ITK_user_main(int argc, char** argv)
{
    int   retcode = ITK_ok;
    char* szPasswdFile = NULL;
    char* sp_user = NULL;
    char* sp_group = NULL;
    char* sp_input_file = NULL;
    char* sp_log_file = NULL;
    tag_t group_tag = NULLTAG;

    int nDS = 0;
    tag_t* tDS = NULL;


    /* Check Command Line Arguments */
    if (ITK_ask_cli_argument("-u="))
        sp_user = ITK_ask_cli_argument("-u=");
    if (ITK_ask_cli_argument("-pf="))
        szPasswdFile = ITK_ask_cli_argument("-pf=");
    if (ITK_ask_cli_argument("-g="))
        sp_group = ITK_ask_cli_argument("-g=");
    if (ITK_ask_cli_argument("-input_file="))
        sp_input_file = ITK_ask_cli_argument("-input_file=");
    if (ITK_ask_cli_argument("-log="))
        sp_log_file = ITK_ask_cli_argument("-log=");

    /* check arguments */
    if (ITK_ask_cli_argument("-h") || ITK_ask_cli_argument("-help"))
    {
        display_usage(argv[0]);
        return ITK_ok;
    }

    if (sp_log_file != NULL) {
        _logfile.open(sp_log_file);
        if (_logfile.is_open())
            logFileSet = true;
        else {
            std::cerr << "Failed to open log file for writeing" << std::endl;
            return 0;
        }
    }


    /* login */
    retcode = startup_ITK(sp_user, szPasswdFile, sp_group);
    if (retcode != ITK_ok) {
        std::cerr << "ERROR: unable to login" << std::endl;
        return retcode;
    }

    if (sp_group == NULL)
    {
        RETURN_ERROR(POM_ask_group(&sp_group, &group_tag));
    }
    if (!strcmp(sp_group, "dba")) {
        retcode = ITK_set_bypass(true);
        std::cout << "setting bypass on" << std::endl;
    }

    std::cout << std::endl << std::endl << "-----------------------------------------------------------------------" << std::endl;


    RETURN_ERROR(POM_set_env_info(POM_bypass_attr_update, FALSE, 0, 0.0, NULLTAG, NULL));
    RETURN_ERROR(POM_set_env_info(POM_bypass_access_check, TRUE, 0, 0.0, NULLTAG, NULL));

    RETURN_ERROR(change_types(sp_input_file));

    if (logFileSet)
        _logfile.close();

    return 0;
}

static int startup_ITK(
    char* sp_user,
    char* szPasswdFile,
    char* sp_group)
{
    int		retcode = ITK_ok;

    if (sp_user != NULL && szPasswdFile != NULL) {
        std::cout << "ITK-Login with -pf." << std::endl;
        RETURN_ERROR(ITK_auto_login());
    }
    else {
        printf("\n\nITK-Auto-Login.\n");
        RETURN_ERROR(ITK_auto_login());
    }

    RETURN_ERROR(ITK_initialize_text_services(ITK_BATCH_TEXT_MODE));

    RETURN_ERROR(ITK_set_journalling(TRUE));
    RETURN_ERROR(SA_init_module());
    RETURN_ERROR(AOM_init_module());

    return (retcode);
}


/**************************************************************************/
/* shutdown ITK Environment                                               */
/**************************************************************************/
static int exit_ITK()
{
    int		retcode = ITK_ok;

    RETURN_ERROR(ITK_exit_module(true));

    return retcode;
}


static void display_usage(
    char* s_application)
{
    std::cout << "Usage:	" << s_application << std::endl;
    std::cout << "  -u=<user>" << std::endl;
    std::cout << "  -pf=<password file>" << std::endl;
    std::cout << "  -g=<group>" << std::endl;
    std::cout << "  -input_file=<file> in absolute path, flat text file, containing Type Configurations and Item IDs to change" << std::endl;
    std::cout << "                     Format Line 1: <ItemType>;<RevisionType>;<ItemMasterType>;<ItemRevMasterType>" << std::endl;
    std::cout << "  -log=<file> in absolute path to log file" << std::endl;
    std::cout << "  -h[elp] : this output." << std::endl;
}

static int change_types(const char* input_file) {
    int retcode = ITK_ok;
    std::vector<std::string> targetTypes;
    std::regex const re = std::regex{ R"(;+)" };

    std::ifstream inputFile(input_file);
    std::string line;

    std::cout << "Reading " << input_file << std::endl;
    if (inputFile.is_open()) {
        int line_no = 2;
        if (std::getline(inputFile, line)) { // read first line Format <ItemType>;<RevisionType>;<ItemMasterType>;<ItemRevMasterType>
            std::cout << "Parsing types: " << line << std::endl;
            logStream << "Parsing types: " << line << std::endl;
            targetTypes = std::vector<std::string>(
                std::sregex_token_iterator{ begin(line), end(line), re, -1 },
                std::sregex_token_iterator{}
            );

            if (targetTypes.size() != 4) {
                std::cerr << "ERROR: invalid format in input line. Expected <ItemType>;<RevisionType>;<ItemMasterType>;<ItemRevMasterType> in first line" << std::endl;
                logStream << "ERROR: invalid format in input line. Expected <ItemType>;<RevisionType>;<ItemMasterType>;<ItemRevMasterType> in first line" << std::endl;
                return !ITK_ok;
            }

            // check whether types exist:
            bool typeError = false;
            for (int i = 0; i < 4; ++i) {
                tag_t tType = NULLTAG;
                std::cout << "Checking type: " << targetTypes[i] << std::endl;
                logStream << "Checking type: " << targetTypes[i] << std::endl;

                retcode = TCTYPE_find_type(targetTypes[i].c_str(), NULL, &tType);
                if (retcode != ITK_ok || tType == NULLTAG) {
                    std::cerr << "ERROR: could not find type <" << targetTypes[i] << ">" << std::endl;
                    logStream << "ERROR: could not find type <" << targetTypes[i] << ">" << std::endl;
                    typeError = true;
                }
            }

            if (typeError)
                return !ITK_ok;
        }

        while (std::getline(inputFile, line)) {
            std::cout << "Line " << line_no   << ":  " << line << ": ";
            logStream << "Line " << line_no++ << ":  " << line << ": ";
            tag_t tItem = NULL;
            retcode = ITEM_find_item(line.c_str(), &tItem);
            if (retcode == ITK_ok && tItem != NULLTAG) {
                change_item_type(tItem, targetTypes);
            }
            else {
                std::cout << "FIND Item failed (" << retcode << ")";
                logStream << "FIND Item failed (" << retcode << ")";
            }
            std::cout << std::endl;
            logStream << std::endl;
        }
    }

    return ITK_ok;

}

static bool check_type(tag_t tObject, const std::string& sType) {
    int retcode = ITK_ok;

    char* sTypeName = NULL;
    bool result = false;
    
    retcode = WSOM_ask_object_type2(tObject, &sTypeName);
    if (retcode == ITK_ok) {
        result = sType == sTypeName;
    }

    return result;
}

static int change_item_type(tag_t tItem, const std::vector<std::string>& types) {
    int retcode = ITK_ok;
    tag_t tItemMaster = NULLTAG;
    int nRevisions = 0;
    tag_t* tRevisions = NULL;
    tag_t* tRevisionMaster = NULL;
    bool fail = false;
    bool typeChangeNeeded = false;
    logical isCorrectType = false;


    isCorrectType = check_type(tItem, types[0]);


    retcode = AOM_ask_value_tag(tItem, "item_master_tag", &tItemMaster);

    if (retcode != ITK_ok || tItemMaster == NULLTAG) {
        fail = true;
        std::cerr << "ERROR could not locate ItemMaster" << std::endl;
        logStream << "ERROR could not locate ItemMaster" << std::endl;
    }
    else {
        isCorrectType &= check_type(tItemMaster, types[2]);
    }


    retcode = AOM_ask_value_tags(tItem, "revision_list", &nRevisions, &tRevisions);
    if (retcode != ITK_ok || nRevisions == 0) {
        fail = true;
        std::cerr << "ERROR could not locate ItemMaster" << std::endl;
        logStream << "ERROR could not locate ItemMaster" << std::endl;
    }
    else {
        tag_t tRevMasteRel = NULLTAG;

        retcode = GRM_find_relation_type("IMAN_master_form", &tRevMasteRel);

        tRevisionMaster = (tag_t*)MEM_alloc(nRevisions * sizeof(tag_t));

        for (int i = 0; i < nRevisions; i++) {
            int nMaster = 0;
            tag_t *tRevMaster = NULL;

            isCorrectType &= check_type(tRevisions[i], types[1]);

            retcode = GRM_list_secondary_objects_only(tRevisions[i], tRevMasteRel, &nMaster, &tRevMaster);

            if (retcode != ITK_ok || nMaster != 1) {
                fail = true;
                std::cerr << "ERROR could not locate ItemRevMaster: error (" << retcode << ") masters(" << nMaster << ")" << std::endl;
                logStream << "ERROR could not locate ItemRevMaster: error (" << retcode << ") masters(" << nMaster << ")" << std::endl;
                isCorrectType = false;
            }
            else {
                tRevisionMaster[i] = tRevMaster[0];
                isCorrectType &= check_type(tRevisionMaster[i], types[3]);
            }

            STD_FREE(tRevMaster);
        }
    }

    if (isCorrectType) {
        std::cout << " Type is already correct";
        logStream << " Type is already correct";
    }

    if (!fail && isCorrectType == false) {
        tag_t tAttr = NULLTAG;
        tag_t* tRev = NULL;
        int nChanges = 0;
        int nMarkPoint = -1;
        char* sID = NULL;

        std::cout << " Changing Type";
        logStream << " Changing Type: ";

        POM_tag_to_string(tItem, &sID);
        if (sID) {
            logStream << "Item UID: " << sID;
            STD_FREE(sID);
        }
        POM_tag_to_string(tItemMaster, &sID);
        if (sID) {
            logStream << " - Item Master UID: " << sID;
            STD_FREE(sID);
        }
        for (int i = 0; i < nRevisions; i++) {
            POM_tag_to_string(tRevisions[i], &sID);
            if (sID) {
                logStream << " - Item Rev (" << i << ") UID: " << sID;
                STD_FREE(sID);
            }
            POM_tag_to_string(tRevisionMaster[i], &sID);
            if (sID) {
                logStream << " - ItemRevMaster (" << i << "): " << sID;
                STD_FREE(sID);
            }
        }


        LOG_AND_PROCEED("Place Markpoint", POM_place_markpoint(&nMarkPoint));
        LOG_AND_PROCEED("get attr id", POM_attr_id_of_attr("object_type", "WorkspaceObject", &tAttr));

        LOG_AND_PROCEED("unload Item", unload_instances(1, &tItem));
        LOG_AND_PROCEED("unload ItemMaster", unload_instances(1, &tItemMaster));
        LOG_AND_PROCEED("unload Revisions", unload_instances(nRevisions, tRevisions));
        LOG_AND_PROCEED("unload RevisionMasters", unload_instances(nRevisions, tRevisionMaster));

        LOG_AND_PROCEED("load and lock Item", POM_load_instances_any_class(1, &tItem, POM_modify_lock));
        LOG_AND_PROCEED("load and lock ItemMaster", POM_load_instances_any_class(1, &tItemMaster, POM_modify_lock));
        LOG_AND_PROCEED("load and lock Revisions", POM_load_instances_any_class(nRevisions, tRevisions, POM_modify_lock));
        LOG_AND_PROCEED("load and lock RevisionMasters", POM_load_instances_any_class(nRevisions, tRevisionMaster, POM_modify_lock));
      
        LOG_AND_PROCEED("update Item type", POM_set_attr_string(1, &tItem, tAttr, types[0].c_str()));
        LOG_AND_PROCEED("update ItemMaster type", POM_set_attr_string(1, &tItemMaster, tAttr, types[2].c_str()));
        LOG_AND_PROCEED("update ItemRevision type", POM_set_attr_string(nRevisions, tRevisions, tAttr, types[1].c_str()));
        LOG_AND_PROCEED("update ItemRevisionMaster type", POM_set_attr_string(nRevisions, tRevisionMaster, tAttr, types[3].c_str()));

        LOG_AND_PROCEED("save and unlock Item", POM_save_instances(1, &tItem, 1));
        LOG_AND_PROCEED("save and unlock ItemMaster", POM_save_instances(1, &tItemMaster, 1));
        LOG_AND_PROCEED("save and unlock Revision", POM_save_instances(nRevisions, tRevisions, 1));
        LOG_AND_PROCEED("save and unlock RevisionMaster", POM_save_instances(nRevisions, tRevisionMaster, 1));

        if (nMarkPoint != -1)
            if (retcode != ITK_ok) {
                logical dummy;
                LOG_AND_PROCEED("Rollback to markpoint", POM_roll_to_markpoint(nMarkPoint, &dummy));
            }
            else {
                LOG_AND_PROCEED("forget markpoint", POM_forget_markpoint(nMarkPoint));
            }
    }

    STD_FREE(tRevisions);
    STD_FREE(tRevisionMaster);

    return ITK_ok;
}

static int unload_instances(int n, tag_t* tags) {
    for (int i = 0; i < n; i++) {
        logical isLoaded = false;
        POM_is_loaded(tags[i], &isLoaded);
        if (isLoaded)
            POM_unload_instances(1, &(tags[i]));
    }
    return ITK_ok;
}
