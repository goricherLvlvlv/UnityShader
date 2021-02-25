using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
//using UnityEngine.Experimental.LowLevel;

public class ToolCenter : UnityEditor.AssetModificationProcessor
{
    //[InitializeOnLoadMethod]
    //static void InitializeOnLoadMethod()
    //{
    //    EditorApplication.projectChanged += () => { Debug.Log("changed"); };
        
    //    EditorApplication.projectWindowItemOnGUI = delegate (string GUID, Rect selectionRect)
    //    {
    //        if (Selection.activeObject &&
    //            GUID == AssetDatabase.AssetPathToGUID(AssetDatabase.GetAssetPath(Selection.activeObject)))
    //        {
    //            float width = 50.0f;
    //            float height = 16.0f;
    //            selectionRect.x = selectionRect.x + selectionRect.width - width;
    //            selectionRect.width = width;
    //            selectionRect.height = height;
    //            GUI.color = Color.gray;
    //            if (GUI.Button(selectionRect, "Name"))
    //            {
    //                Debug.LogFormat("click name : {0}", Selection.activeObject.name);
    //            }

    //            GUI.color = Color.white;
    //        }
    //    };
    //}

    //public static bool IsOpenForEdit(string assetPath, out string message)
    //{
    //    message = null;
    //    Debug.LogFormat("assetPath : {0}", assetPath);
    //    return true;
    //}

}
