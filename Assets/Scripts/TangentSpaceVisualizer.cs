﻿using UnityEngine;
using System.Collections;

public class TangentSpaceVisualizer : MonoBehaviour
{
    public float offset = 0.01f;
    public float scale = 0.1f;

    private void OnDrawGizmos()
    {
        MeshFilter meshFilter = GetComponent<MeshFilter>();
        if (!meshFilter) return;
        Mesh mesh = meshFilter.sharedMesh;
        if (!mesh) return;

        ShowTagentSpace(mesh);
    }

    private void ShowTagentSpace(Mesh mesh)
    {
        Vector3[] vertices = mesh.vertices;
        Vector3[] normals = mesh.normals;
		Vector4[] tangents = mesh.tangents;

        for (int i = 0; i < vertices.Length; i++)
        {
            ShowTangent(
                transform.TransformPoint(vertices[i]),
                transform.TransformDirection(normals[i]),
				transform.TransformDirection(tangents[i]),
				tangents[i].w);
        }
    }

    private void ShowTangent(
		Vector3 vertex, Vector3 normal, Vector3 tangent, float binormalSign)
    {
		vertex += normal * offset;

        Gizmos.color = Color.green;
        Gizmos.DrawLine(vertex, vertex + normal * scale);

		Gizmos.color = Color.red;
        Gizmos.DrawLine(vertex, vertex + tangent * scale);

		Vector3 binormal = Vector3.Cross(normal, tangent) * binormalSign;
		Gizmos.color = Color.blue;
        Gizmos.DrawLine(vertex, vertex + binormal * scale);		
    }
}
