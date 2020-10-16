using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestMove : MonoBehaviour
{
    private float _h;
    private float _v;
    private Vector3 _move;

    private float lerpVec;

    [Range(0.1f, 5f)]
    public float _moveSpeed = 0.3f;

    [Range(0.01f, 1f)]
    public float _rotationSpeed = 1f;

    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        _h = Input.GetAxisRaw("Horizontal");
        _v = Input.GetAxisRaw("Vertical");

        _move = new Vector3(_h, 0f, _v).normalized;

        LookAt();
        Move();
    }

    private void LookAt()
    {
        if (_move.Equals(Vector3.zero)) return;

        Quaternion targetRot = Quaternion.LookRotation(_move);

        transform.rotation = Quaternion.RotateTowards(transform.rotation, targetRot, Time.deltaTime * _rotationSpeed * 500f);
    }

    private void Move()
    {
        if (_move.Equals(Vector3.zero)) return;

        transform.Translate(_move * _moveSpeed * 0.1f, Space.World);
    }
}
