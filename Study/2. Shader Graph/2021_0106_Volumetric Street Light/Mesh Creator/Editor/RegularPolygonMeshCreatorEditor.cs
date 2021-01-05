using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(RegularPolygonMeshCreator))]
public class RegularPolygonMeshCreatorEditor : Editor
{
    // EnemyEditor와 Enemy는 별개의 클래스이므로 실제 선택된 Enemy를 찾아올수 있어야함
    public RegularPolygonMeshCreator selected;

    // Editor에서 OnEnable은 실제 에디터에서 오브젝트를 눌렀을때 활성화됨
    private void OnEnable()
    {
        // target은 Editor에 있는 변수로 선택한 오브젝트를 받아옴.
        if (AssetDatabase.Contains(target))
        {
            selected = null;
        }
        else
        {
            // target은 Object형이므로 Enemy로 형변환
            selected = (RegularPolygonMeshCreator)target;
        }
    }

    // 유니티가 인스펙터를 GUI로 그려주는함수
    public override void OnInspectorGUI()
    {
        if (selected == null)
            return;

        EditorGUILayout.Space();

        if (selected._radius <= 0f) selected._radius = 1f;
        if (selected._polygonVertex <= 2) selected._polygonVertex = 3;

        selected._radius = EditorGUILayout.FloatField("Radius", selected._radius);
        selected._polygonVertex = EditorGUILayout.IntField("Vertices", selected._polygonVertex);

        if (GUILayout.Button("Create Mesh"))
        {
            selected.CreateMesh();
        }
    }
}
