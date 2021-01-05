using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// 설명 : 실시간으로 커스텀 메시 생성
[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public abstract class CustomMeshCreator : MonoBehaviour
{
    protected MeshFilter _meshFilter;
    protected Mesh _mesh;

    public virtual void CreateMesh()
    {
        TryGetComponent(out _meshFilter);
        _mesh = new Mesh();
        _meshFilter.mesh = _mesh;

        CalculateMesh(out var verts, out var tris);

        _mesh.Clear();
        _mesh.vertices = verts;
        _mesh.triangles = tris;
        _mesh.RecalculateNormals();
    }

    protected abstract void CalculateMesh(out Vector3[] verts, out int[] tris);
}
