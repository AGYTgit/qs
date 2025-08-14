#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <json-c/json.h>
#include <limits.h>
#include <unistd.h>

#define MAX(a, b) ((a) > (b) ? (a) : (b))
#define MIN(a, b) ((a) < (b) ? (a) : (b))

// Helper function to create a deep copy of a JSON object
json_object* create_deep_copy(json_object *jso) {
    if (jso == NULL) {
        return NULL;
    }
    const char* json_str = json_object_to_json_string_ext(jso, JSON_C_TO_STRING_PLAIN);
    if (json_str == NULL) {
        return NULL;
    }
    return json_tokener_parse(json_str);
}

// Function to reverse a JSON array by building a new one in reverse order
void reverseJsonArray(json_object** array) {
    if (*array == NULL || json_object_get_type(*array) != json_type_array) {
        return;
    }
    int len = json_object_array_length(*array);
    if (len <= 1) {
        return;
    }
    
    json_object* reversed_array = json_object_new_array();
    if (reversed_array == NULL) {
        return;
    }
    
    for (int i = len - 1; i >= 0; --i) {
        json_object* obj = json_object_array_get_idx(*array, i);
        // Safely transfer ownership by incrementing the reference count
        json_object_array_add(reversed_array, json_object_get(obj));
    }
    
    json_object_put(*array);
    *array = reversed_array;
}

// Function to create a dummy workspace object
json_object* createDummyWs(int id) {
    json_object* dummyWs = json_object_new_object();
    if (dummyWs == NULL) {
        fprintf(stderr, "Failed to create new JSON object.\n");
        return NULL;
    }
    json_object_object_add(dummyWs, "id", json_object_new_int(id));
    json_object_object_add(dummyWs, "windows", json_object_new_int(0));
    json_object_object_add(dummyWs, "active", json_object_new_boolean(false));
    json_object_object_add(dummyWs, "dummy", json_object_new_boolean(true));
    return dummyWs;
}

// Function to set the active status on a workspace in the JSON array
void setActiveStatus(json_object* allWs, int activeWsId) {
    if (allWs == NULL || json_object_get_type(allWs) != json_type_array) {
        return;
    }
    int array_len = json_object_array_length(allWs);
    for (int i = 0; i < array_len; i++) {
        json_object* wsObj = json_object_array_get_idx(allWs, i);
        json_object* idObj;
        if (json_object_object_get_ex(wsObj, "id", &idObj) == 0) {
            continue;
        }
        if (json_object_get_int(idObj) == activeWsId) {
            json_object_object_add(wsObj, "active", json_object_new_boolean(true));
        } else {
            json_object_object_add(wsObj, "active", json_object_new_boolean(false));
        }
    }
}

// Function to get all workspaces as a JSON object
json_object* getAllWs(int min, int max) {
    char cmd[256];
    // The jq command is now always sorted in ascending order
    snprintf(cmd, sizeof(cmd),
        "hyprctl workspaces -j | jq -c '[.[] | {id: .id, windows: .windows, active: false, dummy: false} | select(.id >= %d and .id <= %d)] | sort_by(.id)'", 
        min, max);
    FILE* fp = popen(cmd, "r");
    if (fp == NULL) {
        fprintf(stderr, "Failed to run: %s\n", cmd);
        return NULL;
    }
    char* allWs = NULL;
    char buffer[256];
    size_t total_size = 0;
    while (fgets(buffer, sizeof(buffer), fp) != NULL) {
        size_t buffer_len = strlen(buffer);
        allWs = realloc(allWs, total_size + buffer_len + 1);
        if (allWs == NULL) {
            fprintf(stderr, "Memory reallocation failed.\n");
            pclose(fp);
            return NULL;
        }
        memcpy(allWs + total_size, buffer, buffer_len);
        total_size += buffer_len;
        allWs[total_size] = '\0';
    }
    pclose(fp);
    if (allWs == NULL) {
        return NULL;
    }
    json_object* json_obj = json_tokener_parse(allWs);
    free(allWs); 
    return json_obj;
}

// Function to get the active workspace ID
int getActiveWsId() {
    const char* cmd = "hyprctl activeworkspace -j | jq .id";
    FILE* fp = popen(cmd, "r");
    if (fp == NULL) {
        fprintf(stderr, "Failed to run: %s\n", cmd);
        return -1;
    }
    char buffer[16];
    if (fgets(buffer, sizeof(buffer), fp) == NULL) {
        fprintf(stderr, "Failed to read output from: %s\n", cmd);
        pclose(fp);
        return -1;
    }
    pclose(fp);
    return atoi(buffer);
}

// Corrected function to get workspace IDs
int getWsIds(json_object* allWs, int** allId, int* allIdLen) {
    if (allWs == NULL || json_object_get_type(allWs) != json_type_array) {
        return -1;
    }
    int arrLen = json_object_array_length(allWs);
    if (arrLen == 0) {
        *allId = NULL;
        *allIdLen = 0;
        return 0;
    }
    int* ids = malloc(arrLen * sizeof(int));
    if (ids == NULL) {
        return -1;
    }
    int foundIdCount = 0;
    for (int i = 0; i < arrLen; i++) {
        json_object* wsObj = json_object_array_get_idx(allWs, i);
        json_object* idObj;
        if (json_object_object_get_ex(wsObj, "id", &idObj) == 0) {
            continue;
        }
        ids[foundIdCount] = json_object_get_int(idObj);
        foundIdCount++;
    }
    if (foundIdCount == 0) {
        free(ids);
        *allId = NULL;
        *allIdLen = 0;
        return 0;
    }
    int* resized_ids = realloc(ids, foundIdCount * sizeof(int));
    if (resized_ids != NULL) {
        *allId = resized_ids;
    } else {
        *allId = ids;
    }
    *allIdLen = foundIdCount;
    return 0;
}

// Helper function to check if an ID exists in the realId array
bool idExists(const int* realId, int realIdLen, int id) {
    for (int i = 0; i < realIdLen; ++i) {
        if (realId[i] == id) {
            return true;
        }
    }
    return false;
}

// Corrected function to add dummy workspaces, always including real ones
void addDummyWs(json_object** allWs, int min, int max, int fill) {
    int* realId = NULL;
    int realIdLen = 0;
    if (getWsIds(*allWs, &realId, &realIdLen) != 0) {
        return;
    }
    
    int fillStart = 0;
    int fillEnd = 0;

    switch (fill) {
        case 0: { // none
            break;
        }
        case 1: { // highest-lowest (range from lowest real ID to highest real ID)
            if (realIdLen >= 1) {
                fillStart = realId[0];
                fillEnd = realId[realIdLen - 1];
            }
            break;
        }
        case 2: { // top-highest (range from highest real ID to top (max))
            if (realIdLen >= 1) {
                fillStart = realId[realIdLen - 1];
                fillEnd = max;
            }
            break;
        }
        case 3: { // top-lowest (range from lowest real ID to top (max))
            if (realIdLen >= 1) {
                fillStart = realId[0];
                fillEnd = max;
            }
            break;
        }
        case 4: { // bottom-highest (range from bottom (min) to highest real ID)
            if (realIdLen >= 1) {
                fillStart = min;
                fillEnd = realId[realIdLen - 1];
            }
            break;
        }
        case 5: { // bottom-lowest (range from bottom (min) to lowest real ID)
            if (realIdLen >= 1) {
                fillStart = min;
                fillEnd = realId[0];
            }
            break;
        }
        case 6: { // top-bottom (range from bottom (min) to top (max))
            fillStart = min;
            fillEnd = max;
            break;
        }
    }

    if (fillStart > 0 && fillEnd > 0) {
        int global_min = MIN(min, fillStart);
        int global_max = MAX(max, fillEnd);
        if (realIdLen > 0) {
            global_min = MIN(global_min, realId[0]);
            global_max = MAX(global_max, realId[realIdLen-1]);
        }
        
        json_object* newAllWs = json_object_new_array();
        int realId_idx = 0;
        
        for (int i = global_min; i <= global_max; ++i) {
            bool is_real = idExists(realId, realIdLen, i);
            if (is_real) {
                json_object* realWsObj = NULL;
                while (realId_idx < json_object_array_length(*allWs)) {
                    json_object* temp_obj = json_object_array_get_idx(*allWs, realId_idx);
                    json_object* temp_id_obj;
                    if (json_object_object_get_ex(temp_obj, "id", &temp_id_obj) && json_object_get_int(temp_id_obj) == i) {
                        realWsObj = temp_obj;
                        break;
                    }
                    realId_idx++;
                }
                if (realWsObj != NULL) {
                    json_object_array_add(newAllWs, create_deep_copy(realWsObj));
                }
            } else if (i >= fillStart && i <= fillEnd) {
                json_object_array_add(newAllWs, createDummyWs(i));
            }
        }
        json_object_put(*allWs);
        *allWs = newAllWs;
    }
    if (realId != NULL) {
        free(realId);
    }
}

int parseArgs(int argc, char* argv[], int* min, int* max, int* fill, bool* reverse) {
    if (argc < 5) return -1;
    *min = atoi(argv[1]);
    *max = atoi(argv[2]);
    *fill = atoi(argv[3]);
    if (strcmp(argv[4], "true") == 0) {
        *reverse = true;
    } else {
        *reverse = false;
    }
    return 0;
}

int main(int argc, char* argv[]) {
    if (argc != 5) {
        fprintf(stderr, "Wrong args\n");
        return 1;
    }
    int min, max, fill;
    bool reverse;
    if (parseArgs(argc, argv, &min, &max, &fill, &reverse) != 0) {
        fprintf(stderr, "Failed to parse args\n");
        return 1;
    }
    int activeWsId = getActiveWsId();
    json_object* allWs = getAllWs(min, max);
    if (allWs == NULL || json_object_get_type(allWs) != json_type_array) {
        fprintf(stderr, "Error: getAllWs did not return a valid JSON array.\n");
        if (allWs != NULL) { json_object_put(allWs); }
        return 1;
    }

    addDummyWs(&allWs, min, max, fill);

    setActiveStatus(allWs, activeWsId);

    if (reverse) {
        reverseJsonArray(&allWs);
    }

    printf("%s\n", json_object_to_json_string_ext(allWs, JSON_C_TO_STRING_PLAIN));
    json_object_put(allWs);
    return 0;
}
