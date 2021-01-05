using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(PrismMeshCreator))]
public class PrismMeshCreatorEditor : Editor
{
    public PrismMeshCreator selected;

    private void OnEnable()
    {
        selected = 
            AssetDatabase.Contains(target) ? null : (PrismMeshCreator)target;
    }

    public override void OnInspectorGUI()
    {
        if (selected == null)
            return;

        EditorGUILayout.Space();

        if (selected._topRadius    <= 0f) selected._topRadius = 1f;
        if (selected._bottomRadius <= 0f) selected._bottomRadius = 1f;
        if (selected._height       <= 0f) selected._height = 1f;
        if (selected._polygonVertex <= 2) selected._polygonVertex = 3;

        selected._topRadius     = EditorGUILayout.FloatField("Top Radius", selected._topRadius);
        selected._bottomRadius  = EditorGUILayout.FloatField("Bottom Radius", selected._bottomRadius);
        selected._height        = EditorGUILayout.FloatField("Height", selected._height);
        selected._polygonVertex = EditorGUILayout.IntField("Vertices", selected._polygonVertex);

        if (GUILayout.Button("Create Mesh"))
        {
            selected.CreateMesh();
        }
    }
}
