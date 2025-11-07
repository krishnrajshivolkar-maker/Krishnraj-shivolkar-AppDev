package com.example.counter;

import androidx.appcompat.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

public class MainActivity extends AppCompatActivity {

    private int counter = 0;
    private TextView tvCounter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Connect UI elements
        tvCounter = findViewById(R.id.tvCounter);
        Button btnIncrement = findViewById(R.id.btnIncrement);
        Button btnDecrement = findViewById(R.id.btnDecrement);
        Button btnReset = findViewById(R.id.btnReset);

        // Increment
        btnIncrement.setOnClickListener(v -> {
            counter++;
            tvCounter.setText(String.valueOf(counter));
        });

        // Decrement
        btnDecrement.setOnClickListener(v -> {
            counter--;
            tvCounter.setText(String.valueOf(counter));
        });

        // Reset
        btnReset.setOnClickListener(v -> {
            counter = 0;
            tvCounter.setText(String.valueOf(counter));
        });
    }
}
