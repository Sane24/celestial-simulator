using UnityEngine;

[ExecuteAlways]
[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class AuroraCurtainMesh : MonoBehaviour
{
    [Header("Mesh Settings")]
    public int widthSegments = 100;
    public int heightSegments = 20;
    public float width = 20f;
    public float height = 15f;

    [Header("S-Curve Settings")]
    public float waveAmplitude = 4f;
    public float waveFrequency = 2f;

    [Header("Ripple Animation")]
    public float rippleSpeed = 1.0f;
    public float rippleAmplitude = 0.3f;
    public float rippleFrequency = 2.5f;

    private MeshFilter meshFilter;
    private Mesh mesh;
    private Vector3[] baseVertices;

    void Awake()
    {
        meshFilter = GetComponent<MeshFilter>();
        GenerateMesh();
    }

    void OnValidate()
    {
        if (!Application.isPlaying && meshFilter != null)
        {
            GenerateMesh();
        }
    }

    void GenerateMesh()
    {
        mesh = new Mesh();
        mesh.name = "Aurora Curtain Mesh";

        int vertCount = (widthSegments + 1) * (heightSegments + 1);
        Vector3[] vertices = new Vector3[vertCount];
        Vector2[] uvs = new Vector2[vertCount];
        int[] triangles = new int[widthSegments * heightSegments * 6];

        int vertIndex = 0;
        int triIndex = 0;

        for (int y = 0; y <= heightSegments; y++)
        {
            float v = (float)y / heightSegments;
            float yPos = v * height;

            for (int x = 0; x <= widthSegments; x++)
            {
                float u = (float)x / widthSegments;
                float xPos = (u - 0.5f) * width;

                // S-curve via sine wave in Z direction
                float zPos = Mathf.Sin(u * Mathf.PI * waveFrequency) * waveAmplitude;

                vertices[vertIndex] = new Vector3(xPos, yPos, zPos);
                uvs[vertIndex] = new Vector2(u, v);

                if (x < widthSegments && y < heightSegments)
                {
                    int current = vertIndex;
                    int nextRow = current + widthSegments + 1;

                    triangles[triIndex++] = current;
                    triangles[triIndex++] = nextRow;
                    triangles[triIndex++] = current + 1;

                    triangles[triIndex++] = current + 1;
                    triangles[triIndex++] = nextRow;
                    triangles[triIndex++] = nextRow + 1;
                }

                vertIndex++;
            }
        }

        mesh.vertices = vertices;
        mesh.uv = uvs;
        mesh.triangles = triangles;
        mesh.RecalculateNormals();
        mesh.RecalculateBounds();

        meshFilter.sharedMesh = mesh;
        baseVertices = mesh.vertices;
    }

    void Update()
    {
        if (mesh == null || baseVertices == null)
            return;

        Vector3[] animatedVertices = new Vector3[baseVertices.Length];
        float time = Time.time * rippleSpeed;

        for (int i = 0; i < baseVertices.Length; i++)
        {
            Vector3 v = baseVertices[i];

            // Animate ripple with vertical dependency (better wave travel)
            float ripple = Mathf.Sin(v.x * rippleFrequency + v.y * 0.5f + time) * rippleAmplitude;

            // Apply ripple to Z (depth)
            v.z += ripple;
            animatedVertices[i] = v;
        }

        mesh.vertices = animatedVertices;
        mesh.RecalculateNormals();
        mesh.RecalculateBounds();
    }
}
